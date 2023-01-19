package widgets

import (
	"context"
	"lambda/health"

	"github.com/aws/aws-lambda-go/lambdacontext"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/codepipeline"
	"github.com/aws/aws-sdk-go/service/ssm"
)

type CicdHealthRequest struct {
	Pipelines map[string]Pipeline `json:"pipelines"`
	Update    bool                `json:"update"`
}

type Pipeline struct {
	CodepipelineName           string `json:"codepipeline_name"`
	SsmParameterName           string `json:"ssm_parameter_name"`
	TargetKind                 string `json:"target_kind"`
	Version                    string `json:"version"`
	PipelineExecutionSummaries []*codepipeline.PipelineExecutionSummary
}

type CicdHealth struct {
	Pipelines   map[string]Pipeline `json:"pipelines"`
	FunctionArn string
}

func NewCicdHealth(ctx context.Context, request CicdHealthRequest, wctx health.WidgetContext) (*CicdHealth, error) {
	lc, _ := lambdacontext.FromContext(ctx)

	h := CicdHealth{
		FunctionArn: lc.InvokedFunctionArn,
		Pipelines:   request.Pipelines,
	}

	sess, err := session.NewSession()
	if err != nil {
		return nil, err
	}

	codepipelineClient := codepipeline.New(sess)
	ssmClient := ssm.New(sess)

	for name, params := range request.Pipelines {
		codepipelineInput := codepipeline.ListPipelineExecutionsInput{
			PipelineName: &params.CodepipelineName,
			MaxResults:   aws.Int64(5),
		}

		executions, err := codepipelineClient.ListPipelineExecutions(&codepipelineInput)
		if err != nil {
			return nil, err
		}

		ssmInput := ssm.GetParameterInput{
			Name:           &params.SsmParameterName,
			WithDecryption: aws.Bool(true),
		}

		param, err := ssmClient.GetParameter(&ssmInput)
		if err != nil {
			return nil, err
		}

		if pipeline, ok := h.Pipelines[name]; ok {
			pipeline.PipelineExecutionSummaries = executions.PipelineExecutionSummaries
			pipeline.Version = *param.Parameter.Value

			h.Pipelines[name] = pipeline
		}

		if request.Update {
			value := wctx.Forms["all"][params.SsmParameterName]

			ssmInput := ssm.PutParameterInput{
				Name:      &params.SsmParameterName,
				Value:     &value,
				Overwrite: aws.Bool(true),
			}

			_, err := ssmClient.PutParameter(&ssmInput)
			if err != nil {
				return nil, err
			}
		}
	}

	return &h, nil
}

func (h CicdHealth) Html() string {
	const template = `
    <table>
		<tr>
			<th>Name</th>
			<th>Kind</th>
			<th>Deployment Status</th>
			<th>Version</th>
		</tr>

		{{ range $key, $value := .Pipelines }}
		<tr>
			<td>{{ $key }}</td>
			<td>{{ $value.TargetKind }}</td>

			{{ if eq (DerefStr (index $value.PipelineExecutionSummaries 0).Status) "Failed" }}
				<td class="has-details bad">
			{{ else if eq (DerefStr (index $value.PipelineExecutionSummaries 0).Status) "Succeeded" }}
				<td class="has-details good">
			{{ else }}
				<td class="has-details suspect">
			{{ end }}

				{{ (index $value.PipelineExecutionSummaries 0).Status }}

				<span class="details">
					<table>
						<tr>
							<th>Status</th>
							<th>Start Time</th>
							<th>Trigger</th>
						</tr>
						{{ range $value.PipelineExecutionSummaries }}
						<tr>
							{{ if eq (DerefStr .Status) "Failed" }}
								<td style='color:red'>{{ .Status }}</td>
							{{ else if eq (DerefStr .Status) "Succeeded" }}
								<td style='color:green'>{{ .Status }}</td>
							{{ else }}
								<td style='color:orange'>{{ .Status }}</td>
							{{ end }}

							<td>{{ .StartTime }}</td>
							<td>{{ .Trigger.TriggerType }}</td>
						</tr>
						{{ end }}
					</table>
				</span>
			</td>

			<td>
				<input type="text" name="{{ $value.SsmParameterName }}" value="{{ $value.Version }}" style="width: 100%"/>
			</td>
		</tr>
		{{ end }}
	</table>

	<a class='btn btn-primary' style='float: left'>Deploy</a>
	<cwdb-action action='call' endpoint='{{ .FunctionArn }}' display='widget'>
		{
			"kind"      : "cicd",
			"mode"      : "html",
			"pipelines" : {{ Marshal .Pipelines }},
			"update"    : true
		}
	</cwdb-action>
	`

	return GenerateHtml(template, h)
}

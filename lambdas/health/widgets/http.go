package widgets

import (
	"context"
	"net/http"
	"time"
)

type EndpointRequest struct {
	Url   string `json:"url"`
	Query string `json:"query"`
}

type EndpointReponse struct {
	HttpResponse *http.Response `json:"http_response"`
	Url          string         `json:"url"`
	Query        string         `json:"query"`
	Error        string
}

type HttpHealthRequest struct {
	Endpoints map[string]EndpointRequest `json:"endpoints"`
}

type HttpHealth struct {
	Endpoints map[string]EndpointReponse `json:"responses"`
}

func NewHttpHealth(ctx context.Context, request HttpHealthRequest) (*HttpHealth, error) {
	h := HttpHealth{
		Endpoints: map[string]EndpointReponse{},
	}

	for name, endpoint := range request.Endpoints {
		// TODO - goroutines
		h.Endpoints[name] = GetEndpointHealth(endpoint)
	}

	return &h, nil
}

func GetEndpointHealth(endpoint EndpointRequest) EndpointReponse {
	client := http.Client{
		Timeout: 10 * time.Second,
	}

	httpResponse, err := client.Get(endpoint.Url)

	response := EndpointReponse{
		HttpResponse: httpResponse,
		Url:          endpoint.Url,
		Query:        endpoint.Query,
	}

	if err != nil {
		response.Error = err.Error()
	}
	return response
}

func (h HttpHealth) Html() string {
	const template = `
	<table>
    <tr>
		<th>Name</th>
		<th>Status</th>
		<th>URL</th>
	</tr>

	{{ range $name, $endpoint:= .Endpoints }}
		<tr>
			<td>{{ $name }}</td>

			{{ if (eq $endpoint.Error "") }}
				{{ if (lt $endpoint.HttpResponse.StatusCode 300) }}
					<td class="has-details good">
				{{ else if (lt $endpoint.HttpResponse.StatusCode 400) }}
					<td class="has-details suspect">
				{{ else }}
					<td class="has-details bad">
				{{ end }}

					{{ $endpoint.HttpResponse.Status }}
					<span class="details">
					<pre>{{ JsonQuery $endpoint.HttpResponse.Body $endpoint.Query }}</pre>
					</span>
				</td>
			{{ else }}
				<td class="has-details bad">Error
					<span class="details">
					<pre>{{ $endpoint.Error }}</pre>
					</span>
				</td>
			{{ end }}

			<td><a href="{{ $endpoint.Url }}">{{ $endpoint.Url }}</a></td>

		</tr>
	{{ end }}
	</table>
	`

	return GenerateHtml(template, h)
}

package widgets

import (
	"bytes"
	"encoding/json"
	"html/template"
	"io"
	"log"

	"github.com/savaki/jq"
)

func GenerateHtml(tmpl string, data interface{}) string {
	style := `
    <style>
		table {
		  border-collapse: collapse;
		  width: 100%;
		}
		td, th {
		  border: 1px solid #dddddd;
		  text-align: left;
		  padding: 8px;
		}
		.has-details {
		  position: relative;
		}
		.details {
		  position: absolute;
		  top: 0;
		  transform: scale(0);
		  transition: transform 0.1s ease-in;
		  transform-origin: left;
		  display: inline;
		  z-index: 20;
		}
		.has-details:hover span {
		  transform: scale(1);
		}
		.good {
			color: green;
		}
		.bad {
			color: red;
		}
		.suspect {
			color: orange;
		}
    </style>`

	t, err := template.New("html").Funcs(template.FuncMap{
		"DerefStr": func(x *string) string {
			return *x
		},
		"Marshal": func(v interface{}) template.JS {
			a, _ := json.Marshal(v)
			return template.JS(a)
		},
		"JsonQuery": func(body io.ReadCloser, query string) string {
			if b, err := io.ReadAll(body); err == nil {
				op, err := jq.Parse(query)

				if err != nil {
					return "Could not parse query: " + err.Error()
				}

				value, err := op.Apply(b)
				if err != nil {
					return "Could apply query to body: " + err.Error()
				}

				var out bytes.Buffer
				err = json.Indent(&out, value, "", "  ")
				if err != nil {
					return "Body not JSON: " + err.Error()
				}

				return out.String()
			} else {
				return "Error: Could not read reponse body"
			}
		},
	}).Parse(style + tmpl)

	if err != nil {
		log.Fatal(err)
	}

	var result bytes.Buffer
	t.Execute(&result, data)
	return result.String()
}

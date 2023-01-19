package health

type Request struct {
	Mode          string
	Kind          string
	WidgetContext WidgetContext
}

type WidgetContext struct {
	DashboardName string
	WidgetId      string
	AccountId     string
	Locale        string
	Timezone      interface{}
	Period        int
	IsAutoPeriod  bool
	TimeRange     interface{}
	Theme         string
	LinkCharts    bool
	Title         string
	Forms         map[string]map[string]string
	Params        interface{}
	Width         int
	Height        int
}

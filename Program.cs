using Azure.Monitor.OpenTelemetry.Exporter;
using Azure.Monitor.OpenTelemetry.Profiler;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddApplicationInsightsTelemetry();
builder.Services.AddOpenTelemetry().AddAzureMonitorProfiler();
var app = builder.Build();

app.MapGet("/", () => "Hello World!");

app.Run();

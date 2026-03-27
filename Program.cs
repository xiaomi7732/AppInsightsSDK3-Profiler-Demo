using Azure.Monitor.OpenTelemetry.Profiler;

var builder = WebApplication.CreateBuilder(args);

builder.Services
  .AddApplicationInsightsTelemetry()
  .AddAzureMonitorProfiler();

//builder.Services.AddAzureMonitorProfiler(); // <--
// builder.Services.AddOpenTelemetry().AddAzureMonitorProfiler(cft => );

var app = builder.Build();

app.MapGet("/", () => "Hello World!");

app.Run();

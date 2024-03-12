resource "aws_cloudwatch_dashboard" "helios-fhir-server" {
  dashboard_name = "Helios FHIR Server"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            [ "SELECT AVG(CPUUtilization)\nFROM SCHEMA(\"AWS/EC2\", InstanceId)\nGROUP BY InstanceId\nORDER BY AVG() DESC", "${LABEL} [avg: ${AVG}%]", "q1", "us-east-1" ]
          ]
          view   = "timeSeries"
          stacked = false
          period = 300
          stat   = "Average"
          region = "us-east-1"
          title = "CPU utilization of EC2 instances sorted by highest"
        }
      }
    ]
  })
}
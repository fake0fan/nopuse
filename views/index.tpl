<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css" integrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T" crossorigin="anonymous">
  </head>
  <body>
    <div class="col-md-6 offset-md-3">
      <h2>CPU</h2>
      <div class="card">
        <div class="card-body">
          <canvas id="cpu-utilization"></canvas>
        </div>
        <div class="card-body">
          <canvas id="cpu-saturation"></canvas>
        </div>
      </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/chart.js@2.8.0"></script>
    <script src="https://code.jquery.com/jquery-3.4.0.min.js" integrity="sha256-BJeo0qm959uMBGb65z40ejJYGSgR7REI4+CW1fNKwOg=" crossorigin="anonymous"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js" integrity="sha384-UO2eT0CpHqdSJQ6hJty5KVphtPhzWj9WO1clHTMGa3JDZwrnQq4sF86dIHNDz0W1" crossorigin="anonymous"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js" integrity="sha384-JjSmVgyd0p3pXB1rRibZUAYoIIy6OrQ6VrjIEaFf/nJGzIxFDsf4x0xIM+B07jRM" crossorigin="anonymous"></script>
    <script>
      var cpuUtilizationChartCtx = document.getElementById('cpu-utilization').getContext('2d');
      var cpuSaturationChartCtx = document.getElementById('cpu-saturation').getContext('2d');
			var cpuUtilizationChart = new Chart(cpuUtilizationChartCtx, {
					type: 'line',
					data: {
            labels: [],
            datasets: [{
              label: 'utilization',
              borderColor: 'rgb(51, 153, 255)',
              data: []
            }]},
          options: {
						scales: {
							yAxes: [{
								ticks: {
									min: 0,
									max: 100,
									stepSize: 10
								}
							}]
						}
				  }
      });
			var cpuSaturationChart = new Chart(cpuSaturationChartCtx, {
					type: 'line',
					data: {
            labels: [],
            datasets: [{
              label: 'saturation',
              borderColor: 'rgb(255, 153, 51)',
              data: []
            }]},
          options: {
						scales: {
							yAxes: [{
								ticks: {
									stepSize: 1
								}
							}]
						}
          }
      });
      function refresh() {
        $.get("/data", function(msg, status) {
          var data = JSON.parse(msg);
          console.log(data);
          if (data !== "null") {
            cpuUtilizationChart.data.labels.push(new Date(data.time * 1000).toISOString());
            cpuSaturationChart.data.labels.push(new Date(data.time * 1000).toISOString());
            cpuUtilizationChart.data.datasets[0].data.push(data.utilization);
            cpuSaturationChart.data.datasets[0].data.push(data.saturation);
            cpuUtilizationChart.update();
            cpuSaturationChart.update();
          }
        });
      };
      setInterval(refresh, 1000);
    </script>
  </body>
</html>

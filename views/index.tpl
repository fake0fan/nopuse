<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css" integrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T" crossorigin="anonymous">
  </head>
  <body>
    <div class="container">
      <div class="row">
        <div class="col-md-6 nopadding">
          <div class="card">
            <div class="card-body">
              <canvas id="cpu-utilization"></canvas>
              <canvas id="cpu-saturation"></canvas>
            </div>
          </div>
        </div>
        <div class="col-md-6 nopadding">
          <div class="card">
            <div class="card-body">
              <canvas id="mem-utilization"></canvas>
              <canvas id="mem-saturation"></canvas>
            </div>
          </div>
        </div>
      </div>
      <div class="row">
        <div class="col-md-6 nopadding">
          <div class="card">
            <div class="card-body">
              <canvas id="system-info"></canvas>
            </div>
          </div>
        </div>
      </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/chart.js@2.8.0"></script>
    <script src="https://code.jquery.com/jquery-3.4.0.min.js" integrity="sha256-BJeo0qm959uMBGb65z40ejJYGSgR7REI4+CW1fNKwOg=" crossorigin="anonymous"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js" integrity="sha384-UO2eT0CpHqdSJQ6hJty5KVphtPhzWj9WO1clHTMGa3JDZwrnQq4sF86dIHNDz0W1" crossorigin="anonymous"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js" integrity="sha384-JjSmVgyd0p3pXB1rRibZUAYoIIy6OrQ6VrjIEaFf/nJGzIxFDsf4x0xIM+B07jRM" crossorigin="anonymous"></script>
    <script>
      Chart.plugins.register({
        beforeDraw: function(c) {
          var ctx = c.chart.ctx;
          var backgroundColor = 'white';
          ctx.fillStyle = backgroundColor;
          ctx.fillRect(0, 0, c.chart.width, c.chart.height);
        }
      });
      var cpuUtilizationChartCtx = document.getElementById('cpu-utilization').getContext('2d');
      var cpuSaturationChartCtx = document.getElementById('cpu-saturation').getContext('2d');
      var memUtilizationChartCtx = document.getElementById('mem-utilization').getContext('2d');
      var memSaturationChartCtx = document.getElementById('mem-saturation').getContext('2d');
      var systemInfoChartCtx = document.getElementById('system-info').getContext('2d');
			var cpuUtilizationChart = new Chart(cpuUtilizationChartCtx, {
					type: 'line',
					data: {
            labels: [],
            datasets: [{
              label: 'utilization',
              borderColor: 'rgb(51, 153, 255)',
              data: []
            }, {
              label: 'user',
              borderColor: 'rgb(119, 255, 51)',
              data: []
            }, {
              label: 'system',
              borderColor: 'rgb(255, 113, 51)',
              data: []
            }]},
          options: {
            title: {
              display: true,
              text: 'CPU-Utilization'
            },
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
            title: {
              display: true,
              text: 'CPU-Saturation'
            }
          }
      });
			var memUtilizationChart = new Chart(memUtilizationChartCtx, {
					type: 'line',
					data: {
            labels: [],
            datasets: [{
              label: 'utilization',
              borderColor: 'rgb(225, 5, 3)',
              data: []
            }, {
              label: 'virtual memory',
              borderColor: 'rgb(210, 180, 222)',
              data: []
            }, {
              label: 'free memory',
              borderColor: 'rgb(88, 214, 141)',
              data: []
            }, {
              label: 'buff memory',
              borderColor: 'rgb(133, 146, 158)',
              data: []
            }, {
              label: 'cache memory',
              borderColor: 'rgb(241, 148, 138)',
              data: []
            }]},
          options: {
            title: {
              display: true,
              text: 'MEM-Utilization'
            },
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
			var memSaturationChart = new Chart(memSaturationChartCtx, {
					type: 'line',
					data: {
            labels: [],
            datasets: [{
              label: 'saturation',
              borderColor: 'rgb(244, 208, 63)',
              data: []
            }]},
          options: {
            title: {
              display: true,
              text: 'MEM-Saturation'
            }
          }
      });
			var systemInfoChart = new Chart(systemInfoChartCtx, {
					type: 'line',
					data: {
            labels: [],
            datasets: [{
              label: 'interrupts_per_second',
              borderColor: 'rgb(255, 91, 51)',
              data: []
            }, {
              label: 'context_switches_per_second',
              borderColor: 'rgb(51, 230, 255)',
              data: []
            }]},
          options: {
            title: {
              display: true,
              text: 'SYSTEM'
            }
          }
      });
      function refresh() {
        $.get("/data", function(msg, status) {
          var data = JSON.parse(msg);
          console.log(data);
          if (data !== "null") {
            cpuUtilizationChart.data.labels.push(...data.labels);
            cpuSaturationChart.data.labels.push(...data.labels);
            memUtilizationChart.data.labels.push(...data.labels);
            memSaturationChart.data.labels.push(...data.labels);
            cpuUtilizationChart.data.datasets[0].data.push(...data.cpu_u);
            cpuUtilizationChart.data.datasets[1].data.push(...data.cpu_user);
            cpuUtilizationChart.data.datasets[2].data.push(...data.cpu_system);
            cpuSaturationChart.data.datasets[0].data.push(...data.cpu_s);
            memUtilizationChart.data.datasets[0].data.push(...data.mem_u);
            memSaturationChart.data.datasets[0].data.push(...data.mem_s);
            memUtilizationChart.data.datasets[1].data.push(...data.mem_swap);
            memUtilizationChart.data.datasets[2].data.push(...data.mem_free);
            memUtilizationChart.data.datasets[3].data.push(...data.mem_buff);
            memUtilizationChart.data.datasets[4].data.push(...data.mem_cache);
            systemInfoChart.data.datasets[0].data.push(...data.system_in);
            systemInfoChart.data.datasets[1].data.push(...data.system_cs);
            cpuUtilizationChart.update();
            cpuSaturationChart.update();
            memUtilizationChart.update();
            memSaturationChart.update();
            systemInfoChart.update();
          }
        });
      };
      setInterval(refresh, 2000);
    </script>
  </body>
</html>

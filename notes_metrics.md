# Notes on time-related metrics

## Node-exporter native metrics

See https://github.com/prometheus/node_exporter/blob/master/docs/TIME.md

### timex
Reference https://www.gnu.org/software/libc/manual/2.27/html_node/High-Accuracy-Clock.html

* `node_timex_estimated_error_seconds` 
  seems the simplest metric, but be careful because it may be zero, which is meaningless
* `node_timex_maxerror_seconds`   
  grows in the interval between time adjustments and is typically in the order of seconds.
  Quite pessimistic and not usually significative to assess the actual time sync precision.
* `node_timex_offset_seconds`
  This looks good, and seems to be defined also on hosts where the estimated is not defined 
  (e.g. a RasPI running MoOde, using systemd-timesyncd) .
  * `avg_over_time(node_timex_offset_seconds[1h])` is typically within few ms
  * `stddev_over_time(node_timex_offset_seconds[4h])` seems a promising estimate of sync precision and stability.

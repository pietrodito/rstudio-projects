def tibble2pd(r_tibble_name):
  import pandas as pd
  import rpy2.robjects as ro
  from rpy2.robjects.packages import importr
  from rpy2.robjects import pandas2ri
  r = ro.r
  x = r(r_tibble_name)
  with (ro.default_converter + pandas2ri.converter).context():
    pd_x = ro.conversion.get_conversion().rpy2py(x)
  return pd_x

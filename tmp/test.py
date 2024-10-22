import pandas as pd
import rpy2.robjects as ro
from rpy2.robjects.packages import importr
from rpy2.robjects import pandas2ri

base = importr('base')
utils = importr('utils')

r = ro.r

x = r('mtcars')
with (ro.default_converter + pandas2ri.converter).context():
 pd_x = ro.conversion.get_conversion().rpy2py(x)

writer = pd.ExcelWriter("~/tmp/mtcars.xlsx", engine = "xlsxwriter")


header_hack = pd_x.T.reset_index().T
header_hack.to_excel(writer, sheet_name = "mtcars", startrow = 1,
    startcol = 1, header = None, index = False)
    
  

workbook = writer.book
sheet = workbook.get_worksheet_by_name("mtcars")

sheet.set_column(0, 0, 5)
sheet.hide_gridlines(2)

my_format = workbook.add_format()
my_format.set_align('center')
sheet.set_column('A:FF', None, my_format)

workbook.close()


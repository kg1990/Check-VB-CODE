#maybe can use excel sheet require make this script more sample and useful
require 'pp'
# This is a program to get a dir files copy to the excel cell
#需要check的路径
Path = "E:\\Networkspace\\fasys_dev\\App_Code\\p_excel"
Dir.foreach(Path){|file|
  pp file
}


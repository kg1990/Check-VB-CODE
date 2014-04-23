require 'pathname'
require 'pp'
#判断文件单行是否存在if
def checkIf(line)
    if line["If"] == "If" && line.strip[0..1] == "If"
      return true
    else
        return false
    end
end
  #判断文件单行是否存在else
def checkElse(line)
    if line["Else"] == "Else" && line.strip[0..3] == "Else"
      return true
    else
        return false
    end
end
#判断文件单行是否存在elseif
def checkElseIf(line)
    if line["ElseIf"] == "ElseIf"  && line.strip[0..5] == "ElseIf"
      return true
    else
        return false
    end
end
#判断文件单行是否存在endif
def checkEndIf(line)
  if line["End If"] == "End If" && line.strip[0..5] == "End If"
      return true
    else
      return false
  end
end
#判断是否为注释行
def checkNoUse(line)
    if line.count("'")%2 == 1 && line.lstrip[0] == 39
      return true
    else
      return false
  end
end
#判断是否存在open
def checkOpen(line)
    if (line["open"] == "open" || line["Open"] == "Open") && !line.include?("OpenBook")
      return true
    else
      return false
  end
end
#判断是否存在close
def checkClose(line)
    if (line["close"] == "close" || line["Close"] == "Close")  && !line.include?("CloseBook") && !line.include?("CloseWaiting")
      return true
    else
      return false
  end
end
#判断抓取内容里面是否存在open 和close的对等和不对等
def checkOpenClose(a,startline,endline,log_file_dir)
    mark = 0
    arr = []
    arr << startline
    arr << endline
    a.each{|x|
        if checkOpen(x)
          mark = mark + 1
        elsif checkClose(x)
          mark = mark + 1
        end
    }
    if mark%2 == 1
      str =  "Please Check Line:" + arr.join(",")
      puts str
      WriteLog(log_file_dir,str)
    end
end

#解析文件
def checkFile(file_path,log_file_dir)
  count = 0
  deep = -1
  code_block = []
  linemark = []
  markif = []
  puts "===============  start check File " + file_path+ "=============="
  WriteLog(log_file_dir,"===============  start check File " + file_path+ "==============")
      #开始遍历文件
      IO.foreach(file_path) {|line|
        #记录行号
        count = count + 1
        #判断是否为注释行
        if !checkNoUse(line)
          #判断是elseif 或者是else语句
          if checkElseIf(line) || checkElse(line)
            #添加尾行标记，mark对应需要check的位置
            linemark[deep] << count
            #调用判断抓取内容的方法
            checkOpenClose(code_block[deep],linemark[deep][0],linemark[deep][1],log_file_dir)
            #清空当前抓取块的内容
            code_block[deep] = []
            #清空mark块下标起始位置和结束位置数组
            linemark[deep] = []
            #清空mark标记
            markif[deep] = nil
            #由于是else 或者是else if 重新mark起始行号
            linemark[deep] << count
            #加上mark标记
            markif[deep] = true
          elsif checkEndIf(line)
            #pp line
            #添加尾行标记，mark对应需要check的位置
            linemark[deep] << count
            #调用判断抓取内容的方法
            checkOpenClose(code_block[deep],linemark[deep][0],linemark[deep][1],log_file_dir)
            #清空当前抓取块的内容
            code_block[deep] = []
            #清空mark块下标起始位置和结束位置数组
            linemark[deep] = []
            #清空mark标记
            markif[deep] = nil
            #一层if已经判断完成，深度减去1
            deep = deep - 1
          elsif checkIf(line)
            #pp line
            #开始一个if判断 数组深度加1
            deep = deep + 1
            #初始化深度中的 行号开始标记防止nil报错
            linemark[deep] = []
            #初始化if块内容数组 防止nil报错
            code_block[deep] = []
            #加上mark标记 要往块数据数组中加数据
            markif[deep] = true
            #添加首行标记，mark对应需要check的位置
            linemark[deep] << count
          else
            #判断是否有mark 往数组里面加上数据
            if markif[deep]
              code_block[deep] << line
            end
          end  
        end
      }
      puts "===============  end check File " + file_path+ "=============="
      WriteLog(log_file_dir,"===============  end check File " + file_path+ "==============")
      puts
    end

#解析文件夹
def checkDir(dir_path,log_file_dir)
  Dir.foreach(dir_path){|file|
    if file != "." && file != ".." && file != ".svn" && file != "log"
      path = Pathname.new(dir_path + "\\" + file)
      if path.directory?
        checkDir(dir_path + "\\" + file,log_file_dir)
      elsif path.file? and file.include?(".vb")
        checkFile(dir_path + "\\" + file,log_file_dir)
      end
    end
  }
end 

#写log到磁盘文件
def WriteLog(file_dir,str)
  aFile = File.new(file_dir,"ab")
       aFile.write "\r\n"
       aFile.write str
  aFile.close
end


#需要check的路径
Path = "E:\\Networkspace\\fasys_dev"
#log存放的位置
log_file_dir = "C:\\checkfile.txt"
#console口输出内容
puts "================start Chcek File Programmer Dir " + Path + "======================"
#写入第一行提示log
WriteLog(log_file_dir,"================start Chcek File Programmer Dir " + Path + "======================")
#调用执行方法
checkDir(Path,log_file_dir)

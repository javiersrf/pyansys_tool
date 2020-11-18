import pylabansys as pansys

mpdl = pansys.Apdlpy("ola","mundo")
linha = [1,2,3,4,5]
mpdl.A(linha)
mpdl.create_group("oa","line")
mpdl.save_db("novo");

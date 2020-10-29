import os


class Apdlpy:

    def __init__(self,path_apdl,path_os):
        self.comandos = "FINISH\\n/CLEAR\\n/PREP7\\n"
        self.apdlpath = path_apdl
        self.ospath = path_os
        self.text_path = "comandline.txt"
        self.ready = False
        self.arquivo = open(self.text_path,"w")
    ##comandos de kpoints
    def k(self,n,x,y,z):
        C = "K,"+str(n)+","+str(x)+","+str(y)+","+str(z)+"\\n"
        self.comandos +=C
        

    def kunsel(self):
        C = "KSEL,U,,,all\\n"
        self.comandos +=C

    def kselall(self):
        C = "KSEL,ALL\\n"
        self.comandos +=C
    def kgrupo(self,nomegrupo):
        C = "CM,"+nomegrupo+",KP\\n"
        self.comandos +=C
    ##comandos de linhas
    def l(self,n,x,y,z):
        C = "L,"+str(n)+","+str(x)+","+str(y)+","+str(z)+"\\n"
        self.comandos +=C

    def lunsel(self):
        C = "LSEL,U,,,all\\n"
        self.comandos +=C
    def lselall(self):
        C = "LSEL,ALL\\n"
        self.comandos +=C
        
    def lgrupo(self,nomegrupo):
        C = "CM,"+nomegrupo+",Line\\n"
        self.comandos +=C

    ##comandos de areas
    def Aline(self,listLines):
        C = "AL"
        if len(listLines) >= 3 and len(listLines) <=10:
            for line in listLines:
                C = C+","+str(line)
            else:
                return 0
            C = C+"\\n"
            self.comandos +=C
    def area_line_grupo(self,listLines):
        C = "AL,grupoLsection%s\\n"
        self.comandos +=C
    
    def area_unsel(self):
        C = "ASEL,U,,,all\\n"
        self.comandos +=C
        
    def sel_a_grupo(self,nomegrupo):
        C = "CM,"+nomegrupo+",AREA\\n"
        self.comandos +=C
    def A(self,listkpoints):
        C = "A"
        if len(listkpoints) >= 3 and len(listkpoints) <=10:
            for line in listkpoints:
                C = C+","+str(line)
               
            else:
                return 0
            C = C+"\\n" 
            self.comandos +=C
    ##comandos de grupo
    def create_group(self,nomegrupo,tipo):
        C = "CM,"+str(nomegrupo)+","+str(tipo)+"\\n"
        self.comandos +=C   
    def g_sel(self,grupo):
        C = "CMSEL,S,"+grupo+"\\n"
        self.comandos +=C   


    ##comandos gerais
    def DK(self,kpoint):
        C = "DK,"+kpoint+",All,0.0\\n"
        self.comandos +=C
    def Allsell(self):
        C = "allsel,all"
        self.comandos +=C
    def exportIGE(self,name):
        C = "IGESOUT,"+name+",iges,,0\\n"
        self.comandos +=C
    def save_db(self,nome):
        C = "SAVE,"+nome+",db,,all"
        self.comandos +=C
        with open(self.text_path,"w") as file:
            file.write(self.comandos)
    def execute(self):
        os.system(self.apdlpath+" –b –p projectname -i "+self.text_path+" –o outputfile.txt")
        
        
        
import os


class Apdlpy:

    def __init__(self,path_apdl,path_os):
        self.comandos = ""
        self.apdlpath = path_apdl
        self.ospath = path_os
        self.ready = False
    ##comandos de kpoints
    def k(self,n,x,y,z):
        C = "K,"+str(n)+","+str(x)+","+str(y)+","+str(z)+"\\n"
        

    def kunsel(self):
        C = "KSEL,U,,,all\\n"

    def kselall(self):
        C = "KSEL,ALL\\n"
        
    def kgrupo(self,nomegrupo):
        C = "CM,"+nomegrupo+",KP\\n"
        
    ##comandos de linhas
    def l(self,n,x,y,z):
        C = "L,"+str(n)+","+str(x)+","+str(y)+","+str(z)+"\\n"
        

    def lunsel(self):
        C = "LSEL,U,,,all\\n"

    def lselall(self):
        C = "LSEL,ALL\\n"
        
        
    def lgrupo(self,nomegrupo):
        C = "CM,"+nomegrupo+",Line\\n"


    ##comandos de areas
    def Aline(self,listLines):
        C = "AL"
        if len(listLines) >= 3 and len(listLines) <=10:
            for line in listLines:
                C = C+","+str(line)
            else:
                return 0
            C = C+"\\n" 
    def area_line_grupo(self,listLines):
        C = "AL,grupoLsection%s\\n"
       
    
    def area_unsel(self):
        C = "ASEL,U,,,all\\n"
        
        
    def sel_a_grupo(self,nomegrupo):
        C = "CM,"+nomegrupo+",AREA\\n"

    def A(self,listkpoints):
        C = "A"
        if len(listkpoints) >= 3 and len(listkpoints) <=10:
            for line in listkpoints:
                C = C+","+str(line)
               
            else:
                return 0
            C = C+"\\n" 

    ##comandos de grupo
    def create_group(self,nomegrupo,tipo):
        C = "CM,"+str(nomegrupo)+","+str(tipo)+"\\n"   
    def g_sel(self,grupo):
        C = "CMSEL,S,"+grupo+"\\n"          
    ##comandos gerais
    def DK(self,kpoint):
        C = "DK,"+kpoint+",All,0.0\\n"
    def Allsell(self):
        C = "allsel,all"
    def exportIGE(self,name):
        C = "IGESOUT,"+name+",iges,,0\\n"
        
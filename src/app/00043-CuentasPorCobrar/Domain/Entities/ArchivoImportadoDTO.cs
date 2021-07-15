using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities
{
    public class ArchivoImportadoDTO
    {
        public int I_ImportacionID { get; set; }
        public string T_NomArchivo { get; set; }
        public string T_UrlArchivo { get; set; }
        public int I_CantFilas { get; set; }
        public int I_EntidadID { get; set; }
        public int I_TipoArchivo { get; set; }
        public bool B_Eliminado { get; set; }
        public int? I_UsuarioCre { get; set; }
        public DateTime? D_FecCre { get; set; }
        public int? I_UsuarioMod { get; set; }
        public DateTime? D_FecMod { get; set; }
        public string UserName { get; set; }
        public string T_EntidadDesc { get; set; }
    }
}

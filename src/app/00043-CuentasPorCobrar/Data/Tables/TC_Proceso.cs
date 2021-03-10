using Dapper;
using Data.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Data.Tables
{
    public class TC_Proceso
    {
        public int I_ProcesoID { get; set; }
        public int I_CatPagoID { get; set; }
        public short? I_Anio { get; set; }
        public DateTime? D_FecVencto { get; set; }
        public byte? I_Prioridad { get; set; }
        public int? I_Periodo { get; set; }
        public bool B_Habilitado { get; set; }
        public bool B_Eliminado { get; set; }
        public int? I_UsuarioCre { get; set; }
        public DateTime? D_FecCre { get; set; }
        public int? I_UsuarioMod { get; set; }
        public DateTime? D_FecMod { get; set; }

    }
}

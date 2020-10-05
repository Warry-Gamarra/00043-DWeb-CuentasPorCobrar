using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Data.Tables
{
    public class TS_CorreoAplicacion
    {
        public int I_CorreoID { get; set; }
        public string T_DireccionCorreo { get; set; }
        public string T_PasswordCorreo { get; set; }
        public string T_Seguridad { get; set; }
        public string T_HostName { get; set; }
        public int I_Puerto { get; set; }
        public bool B_Habilitado { get; set; }
        public DateTime D_FecUpdate { get; set; }
        public int? I_ProgramaID { get; set; }
        public string T_ProgramaNom { get; set; }


        public TS_CorreoAplicacion() { }

    }
}

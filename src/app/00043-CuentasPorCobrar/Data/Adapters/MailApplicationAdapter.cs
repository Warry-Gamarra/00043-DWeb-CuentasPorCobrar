using Data.Tables;
using Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Data.Adapters
{
    public class TS_CorreoAplicacionAdapter: MailApplication
    {
        public TS_CorreoAplicacionAdapter(TS_CorreoAplicacion tabla)
        {
            this.ID = tabla.I_CorreoID;
            this.Address = tabla.T_DireccionCorreo;
            this.Password = tabla.T_PasswordCorreo;
            this.SecurityType = tabla.T_Seguridad;
            this.HostName = tabla.T_HostName;
            this.Port = tabla.I_Puerto;
            this.Enabled = tabla.B_Habilitado;
            this.FecUpdated = tabla.D_FecUpdate;
        }
    }
}

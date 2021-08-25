using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Helpers
{
    public struct CuentaDepoEntidad
    {
        public int CuentaDepoId { get; set; }
        public int EntidadFinanId { get; set; }
    }


    public struct Posicion
    {
        public int Inicial { get; set; }
        public int Final { get; set; }
        public int Longitud
        {
            get
            {
                int length = (this.Final - this.Inicial < 0) ? 0 : this.Final - this.Inicial + 1;
                return length;
            }
        }

    }

}

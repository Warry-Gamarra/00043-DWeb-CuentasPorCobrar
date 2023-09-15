using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities
{
    public class CtaDepoServicioDto
    {
        public int ctaDepoServicioID { get; set; }

        public string entidadDesc { get; set; }

        public string numeroCuenta { get; set; }

        public string codServicio { get; set; }

        public string descServ { get; set; }

        public bool habilitado { get; set; }
    }
}

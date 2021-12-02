using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities
{
    public class ServicioBcoComercioDto
    {
        public int I_ServicioID { get; set; }
        public string C_CodServicio { get; set; }
        public string T_DescServ { get; set; }
        public bool B_Habilitado { get; set; }
    }
}

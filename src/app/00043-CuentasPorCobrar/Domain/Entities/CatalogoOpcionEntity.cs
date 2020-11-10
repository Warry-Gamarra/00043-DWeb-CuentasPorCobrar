using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities
{
    public class CatalogoOpcionEntity
    {
        public int I_OpcionID { get; set; }
        public string T_OpcionDesc { get; set; }
        public bool B_Habilitado { get; set; }
    }
}

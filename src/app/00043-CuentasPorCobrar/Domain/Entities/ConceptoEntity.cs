﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities
{
    public class ConceptoEntity
    {
        public int I_ConceptoID { get; set; }
        public string T_ConceptoDesc { get; set; }
        public bool B_EsPagoMatricula { get; set; }
        public bool B_EsPagoExtmp { get; set; }
        public bool B_ConceptoAgrupa { get; set; }
        public bool B_Calculado { get; set; }
        public int I_Calculado { get; set; }
        public decimal I_Monto { get; set; }
        public decimal I_MontoMinimo { get; set; }
        public bool B_Habilitado { get; set; }
        public int? I_UsuarioCre { get; set; }
        public DateTime? D_FecCre { get; set; }
        public int? I_UsuarioMod { get; set; }
        public DateTime? D_FecMod { get; set; }
    }
}

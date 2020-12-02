using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace WebApi.Models
{
    public class MantenimientoAlumnoModel
    {
        public int I_PersonaID { get; set; }

        [Required]
        public string C_NumDNI { get; set; }

        [Required]
        public string C_CodTipDoc { get; set; }

        [Required]
        public string T_ApePaterno { get; set; }

        public string T_ApeMaterno { get; set; }

        [Required]
        public string T_Nombre { get; set; }

        public DateTime? D_FecNac { get; set; }

        public string C_Sexo { get; set; }

        [Required]
        public string C_RcCod { get; set; }

        [Required]
        public string C_CodAlu { get; set; }

        [Required]
        public string C_CodModIng { get; set; }

        [Required]
        public short? C_AnioIngreso { get; set; }

        [Required]
        public int? I_IdPlan { get; set; }

        public bool B_Habilitado { get; set; }

        public bool B_Eliminado { get; set; }

        public MantenimientoAlumnoModel()
        {
            B_Habilitado = true;

            B_Eliminado = false;
        }
    }
}
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace WebApi.Models
{
    public class MantenimientoProgramaUnfvModel
    {
        [Required]
        public string C_RcCod { get; set; }

        public string C_CodEsp { get; set; }

        public string C_CodEsc { get; set; }

        [Required]
        public string C_CodFac { get; set; }

        public string C_Tipo { get; set; }

        public int? I_Duracion { get; set; }

        public bool? B_Anual { get; set; }

        public string N_Grupo { get; set; }

        public string N_Grado { get; set; }

        public int? I_IdAplica { get; set; }

        [Required]
        public string C_CodProg { get; set; }

        [Required]
        public string T_DenomProg { get; set; }

        public string T_Resolucion { get; set; }

        public string T_DenomGrado { get; set; }

        public string T_DenomTitulo { get; set; }

        public string C_CodModEst { get; set; }

        [Required]
        public bool B_SegundaEsp { get; set; }

        public string C_CodRegimenEst { get; set; }

        public string C_CodGrado { get; set; }

        public bool B_Habilitado { get; set; }

        public bool B_Eliminado { get; set; }

        public MantenimientoProgramaUnfvModel()
        {
            B_Habilitado = true;

            B_Eliminado = false;
        }
    }
}
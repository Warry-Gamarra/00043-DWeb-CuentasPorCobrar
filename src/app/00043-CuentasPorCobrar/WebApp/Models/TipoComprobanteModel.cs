using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace WebApp.Models
{
    public class TipoComprobanteModel
    {
        public int? tipoComprobanteID { get; set; }

        [Display(Name = "Cód. Tipo Comprobante")]
        [Required]
        public string tipoComprobanteCod { get; set; }

        [Display(Name = "Descripción")]
        [Required]
        public string tipoComprobanteDesc { get; set; }

        [Display(Name = "Inicial")]
        public string inicial { get; set; }
        
    }
}
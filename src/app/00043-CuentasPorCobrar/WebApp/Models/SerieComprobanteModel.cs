using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace WebApp.Models
{
    public class SerieComprobanteModel
    {
        public int? serieID { get; set; }

        [Display(Name = "Número Serie")]
        [Required]
        public int numeroSerie { get; set; }

        [Display(Name = "Números de serie permitidos")]
        [Required]
        public int finNumeroComprobante { get; set; }

        [Display(Name = "Días de antigüedad")]
        [Required]
        public int diasAnterioresPermitido { get; set; }

        public bool estaHabilitado { get; set; }
    }
}
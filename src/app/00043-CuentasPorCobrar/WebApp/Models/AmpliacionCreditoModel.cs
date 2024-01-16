using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web;

namespace WebApp.Models
{
    public class AmpliacionCreditoModel
    {
        public int procesoId { get; set; }

        public int matAluID { get; set; }

        public decimal monto { get; set; }

        public string sFechaVcto { get; set; }

        public DateTime fechaVcto
        { 
            get
            {
                return DateTime.ParseExact(sFechaVcto, FormatosDateTime.BASIC_DATE, CultureInfo.InvariantCulture);
            }
        }

        public int conceptoID { get; set; }

        public string procesoDesc { get; set; }
    }
}
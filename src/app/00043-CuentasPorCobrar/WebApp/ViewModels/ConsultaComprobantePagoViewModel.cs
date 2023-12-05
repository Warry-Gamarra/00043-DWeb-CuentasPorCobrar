using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web;
using WebApp.Models;

namespace WebApp.ViewModels
{
    public class ConsultaComprobantePagoViewModel
    {
        public bool buscar { get; set; }

        public TipoPago? tipoPago { get; set; }

        public int? entidadFinanciera { get; set; }

        public int? idCtaDeposito { get; set; }

        public string codOperacion { get; set; }

        public string codInterno { get; set; }

        public string codDepositante { get; set; }

        public string nomDepositante { get; set; }

        public string fechaDesde { get; set; }

        public DateTime? fechaInicio
        {
            get
            {
                if (String.IsNullOrWhiteSpace(fechaDesde))
                    return null;

                return DateTime.ParseExact(fechaDesde, FormatosDateTime.BASIC_DATE, CultureInfo.InvariantCulture);
            }
        }

        public string fechaHasta { get; set; }

        public DateTime? fechaFin
        {
            get
            {
                if (String.IsNullOrWhiteSpace(fechaHasta))
                    return null;

                return DateTime.ParseExact(fechaHasta, FormatosDateTime.BASIC_DATE, CultureInfo.InvariantCulture);
            }
        }

        public IEnumerable<ComprobantePagoModel> resultado { get; set; }

        public ConsultaComprobantePagoViewModel()
        {
            resultado = new List<ComprobantePagoModel>();
        }
    }
}
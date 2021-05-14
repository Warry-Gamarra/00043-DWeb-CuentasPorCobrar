using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebApp.ViewModels
{
    public class ReportePagosGeneralesPorFecha
    {
        public string Titulo { get; set; }
        public string CuentaCorriente { get; set; }
        public string FechaInicio { get; set; }
        public string FechaFin { get; set; }
        public string FechaActual { get; }
        public string HoraActual { get; }
        public decimal MontoTotal
        {
            get
            {
                return listaPagos.Sum(p => p.I_MontoTotal);
            }
        }
        public IEnumerable<PagosGeneralesPorFechaViewModel> listaPagos { get; set; }

        public ReportePagosGeneralesPorFecha()
        {
            FechaActual = DateTime.Now.ToString("dd/MM/yyyy");
            HoraActual = DateTime.Now.ToString("HH:mm");
        }
    }
}
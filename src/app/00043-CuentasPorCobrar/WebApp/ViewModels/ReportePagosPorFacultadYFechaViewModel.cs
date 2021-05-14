using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebApp.ViewModels
{
    public class ReportePagosPorFacultadYFechaViewModel
    {
        public string Titulo { get; set; }
        public string CodFac { get; set; }
        public string Facultad { get; set; }
        public string CuentaCorriente { get; set; }
        public string FechaInicio { get; set; }
        public string FechaFin { get; set; }
        public string FechaActual { get; set; }
        public string HoraActual { get; set; }
        public decimal MontoTotal
        {
            get
            {
                return listaPagos.Sum(p => p.I_MontoTotal);
            }
        }
        public IEnumerable<PagosPorFacultadYFechaViewModel> listaPagos { get; set; }

        public ReportePagosPorFacultadYFechaViewModel()
        {
            FechaActual = DateTime.Now.ToString("dd/MM/yyyy");
            HoraActual = DateTime.Now.ToString("HH:mm");
        }
    }
}
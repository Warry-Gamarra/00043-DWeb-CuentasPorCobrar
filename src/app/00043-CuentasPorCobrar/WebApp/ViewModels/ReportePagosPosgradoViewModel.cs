using Domain.Entities;
using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Globalization;
using System.Linq;
using System.Web;

namespace WebApp.ViewModels
{
    public class ReportePagosPorGradoViewModel
    {
        public string Titulo { get; set; }
        public string FechaInicio { get; set; }
        public string FechaFin { get; set; }
        public string FechaActual { get; }
        public string HoraActual { get; }
        public string nombreEntidadFinanc { get; set; }
        public IEnumerable<PagoPosgradoPorGradoDTO> listaPagos { get; }

        public string SubTitulo
        {
            get
            {
                return String.Format("Resumen del {0} al {1}", FechaInicio, FechaFin);
            }
        }
        public decimal MontoTotal
        {
            get
            {
                return listaPagos.Sum(p => p.I_MontoTotal);
            }
        }
        public string T_MontoTotal
        {
            get
            {
                return MontoTotal.ToString(FormatosDecimal.BASIC_DECIMAL);
            }
        }
        
        public ReportePagosPorGradoViewModel(IEnumerable<PagoPosgradoPorGradoDTO> listaPagos)
        {
            FechaActual = DateTime.Now.ToString(FormatosDateTime.BASIC_DATE);
            HoraActual = DateTime.Now.ToString(FormatosDateTime.BASIC_TIME);
            this.listaPagos = listaPagos;
        }
    }



    public class ReportePagosPorConceptoPosgradoViewModel
    {
        public string Titulo { get; set; }
        public string FechaInicio { get; set; }
        public string FechaFin { get; set; }
        public string FechaActual { get; }
        public string HoraActual { get; }
        public string nombreEntidadFinanc { get; set; }
        public IEnumerable<PagoPosgradoPorConceptoDTO> listaPagos { get; }

        public string SubTitulo
        {
            get
            {
                return String.Format("Resumen del {0} al {1}", FechaInicio, FechaFin);
            }
        }
        public decimal MontoTotal
        {
            get
            {
                return listaPagos.Sum(p => p.I_MontoTotal);
            }
        }
        public string T_MontoTotal
        {
            get
            {
                return MontoTotal.ToString(FormatosDecimal.BASIC_DECIMAL);
            }
        }
        
        public ReportePagosPorConceptoPosgradoViewModel(IEnumerable<PagoPosgradoPorConceptoDTO> listaPagos)
        {
            FechaActual = DateTime.Now.ToString(FormatosDateTime.BASIC_DATE);
            HoraActual = DateTime.Now.ToString(FormatosDateTime.BASIC_TIME);
            this.listaPagos = listaPagos;
        }
    }



    public class ReporteConceptosPorGradoViewModel
    {
        public string Titulo { get; set; }
        public string Grado { get; set; }
        public string FechaInicio { get; set; }
        public string FechaFin { get; set; }
        public string FechaActual { get; }
        public string HoraActual { get; }
        public string nombreEntidadFinanc { get; set; }
        public IEnumerable<ConceptoPosgradoPorGradoDTO> listaPagos { get; }

        public string SubTitulo
        {
            get
            {
                return String.Format("Resumen del {0} al {1}", FechaInicio, FechaFin);
            }
        }
        public decimal MontoTotal
        {
            get
            {
                return listaPagos.Sum(p => p.I_MontoTotal);
            }
        }
        public string T_MontoTotal
        {
            get
            {
                return MontoTotal.ToString(FormatosDecimal.BASIC_DECIMAL);
            }
        }

        public ReporteConceptosPorGradoViewModel(IEnumerable<ConceptoPosgradoPorGradoDTO> listaPagos)
        {
            FechaActual = DateTime.Now.ToString(FormatosDateTime.BASIC_DATE);
            HoraActual = DateTime.Now.ToString(FormatosDateTime.BASIC_TIME);
            this.listaPagos = listaPagos;
        }
    }
}
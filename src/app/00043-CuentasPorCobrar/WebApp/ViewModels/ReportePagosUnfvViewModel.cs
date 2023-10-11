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
    public class ReportePagosUnfvGeneralViewModel
    {
        public string Titulo { get; set; }
        public string FechaInicio { get; set; }
        public string FechaFin { get; set; }
        public string FechaActual { get; }
        public string HoraActual { get; }
        public string nombreEntidadFinanc { get; set; }
        public string numeroCuenta { get; set; }
        public IEnumerable<PagoGeneralDTO> listaPagos { get; }

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
        
        public ReportePagosUnfvGeneralViewModel(IEnumerable<PagoGeneralDTO> listaPagos)
        {
            FechaActual = DateTime.Now.ToString(FormatosDateTime.BASIC_DATE);
            HoraActual = DateTime.Now.ToString(FormatosDateTime.BASIC_TIME);
            this.listaPagos = listaPagos;
        }
    }



    public class ReportePagosUnfvPorConceptoViewModel
    {
        public string Titulo { get; set; }
        public string FechaInicio { get; set; }
        public string FechaFin { get; set; }
        public string FechaActual { get; }
        public string HoraActual { get; }
        public string nombreEntidadFinanc { get; set; }
        public string numeroCuenta { get; set; }
        public IEnumerable<PagoPorConceptoDTO> listaPagos { get; }

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
        
        public ReportePagosUnfvPorConceptoViewModel(IEnumerable<PagoPorConceptoDTO> listaPagos)
        {
            FechaActual = DateTime.Now.ToString(FormatosDateTime.BASIC_DATE);
            HoraActual = DateTime.Now.ToString(FormatosDateTime.BASIC_TIME);
            this.listaPagos = listaPagos;
        }
    }



    public class ReportePorDependenciaYConceptoViewModel
    {
        public string Titulo { get; set; }
        public string FechaInicio { get; set; }
        public string FechaFin { get; set; }
        public string FechaActual { get; }
        public string HoraActual { get; }
        public string nombreEntidadFinanc { get; set; }
        public string numeroCuenta { get; set; }
        public IEnumerable<ConceptoPorDependenciaDTO> listaPagos { get; }

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

        public ReportePorDependenciaYConceptoViewModel(IEnumerable<ConceptoPorDependenciaDTO> listaPagos)
        {
            FechaActual = DateTime.Now.ToString(FormatosDateTime.BASIC_DATE);
            HoraActual = DateTime.Now.ToString(FormatosDateTime.BASIC_TIME);
            this.listaPagos = listaPagos;
        }
    }



    public class ReporteConceptosPorDependenciaViewModel
    {
        public string Titulo { get; set; }
        public string Dependencia { get; set; }
        public string FechaInicio { get; set; }
        public string FechaFin { get; set; }
        public string FechaActual { get; }
        public string HoraActual { get; }
        public string nombreEntidadFinanc { get; set; }
        public string numeroCuenta { get; set; }
        public IEnumerable<ConceptoPorDependenciaDTO> listaPagos { get; }

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

        public ReporteConceptosPorDependenciaViewModel(IEnumerable<ConceptoPorDependenciaDTO> listaPagos)
        {
            FechaActual = DateTime.Now.ToString(FormatosDateTime.BASIC_DATE);
            HoraActual = DateTime.Now.ToString(FormatosDateTime.BASIC_TIME);
            this.listaPagos = listaPagos;
        }
    }
}
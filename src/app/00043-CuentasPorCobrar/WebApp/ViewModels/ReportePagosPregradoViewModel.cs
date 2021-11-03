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
    public class ReportePagosPregradoGeneralViewModel
    {
        public string Titulo { get; set; }
        public string FechaInicio { get; set; }
        public string FechaFin { get; set; }
        public string FechaActual { get; }
        public string HoraActual { get; }
        public string nombreEntidadFinanc { get; set; }
        public string numeroCuenta { get; set; }
        public IEnumerable<PagoPregradoGeneralDTO> listaPagos { get; }

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
        

        public ReportePagosPregradoGeneralViewModel(IEnumerable<PagoPregradoGeneralDTO> listaPagos)
        {
            FechaActual = DateTime.Now.ToString(FormatosDateTime.BASIC_DATE);
            HoraActual = DateTime.Now.ToString(FormatosDateTime.BASIC_TIME);
            this.listaPagos = listaPagos;
        }
    }



    public class ReportePagosPregradoPorConceptoViewModel
    {
        public string Titulo { get; set; }
        public string FechaInicio { get; set; }
        public string FechaFin { get; set; }
        public string FechaActual { get; }
        public string HoraActual { get; }
        public string nombreEntidadFinanc { get; set; }
        public string numeroCuenta { get; set; }
        public IEnumerable<PagoPregradoPorConceptoDTO> listaPagos { get; }

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
        
        public ReportePagosPregradoPorConceptoViewModel(IEnumerable<PagoPregradoPorConceptoDTO> listaPagos)
        {
            FechaActual = DateTime.Now.ToString(FormatosDateTime.BASIC_DATE);
            HoraActual = DateTime.Now.ToString(FormatosDateTime.BASIC_TIME);
            this.listaPagos = listaPagos;
        }
    }



    public class ReportePorFacultadYConceptoViewModel
    {
        public string Titulo { get; set; }
        public string FechaInicio { get; set; }
        public string FechaFin { get; set; }
        public string FechaActual { get; }
        public string HoraActual { get; }
        public string nombreEntidadFinanc { get; set; }
        public string numeroCuenta { get; set; }
        public IEnumerable<ConceptoPregradoPorFacultadDTO> listaPagos { get; }

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

        public ReportePorFacultadYConceptoViewModel(IEnumerable<ConceptoPregradoPorFacultadDTO> listaPagos)
        {
            FechaActual = DateTime.Now.ToString(FormatosDateTime.BASIC_DATE);
            HoraActual = DateTime.Now.ToString(FormatosDateTime.BASIC_TIME);
            this.listaPagos = listaPagos;
        }
    }



    public class ReporteConceptosPorFacultadViewModel
    {
        public string Titulo { get; set; }
        public string Facultad { get; set; }
        public string FechaInicio { get; set; }
        public string FechaFin { get; set; }
        public string FechaActual { get; }
        public string HoraActual { get; }
        public string nombreEntidadFinanc { get; set; }
        public string numeroCuenta { get; set; }
        public IEnumerable<ConceptoPregradoPorFacultadDTO> listaPagos { get; }

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

        public ReporteConceptosPorFacultadViewModel(IEnumerable<ConceptoPregradoPorFacultadDTO> listaPagos)
        {
            FechaActual = DateTime.Now.ToString(FormatosDateTime.BASIC_DATE);
            HoraActual = DateTime.Now.ToString(FormatosDateTime.BASIC_TIME);
            this.listaPagos = listaPagos;
        }
    }
}
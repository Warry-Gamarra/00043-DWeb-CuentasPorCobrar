using Domain.Entities;
using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebApp.ViewModels
{
    public class ReporteResumenAnualPagoObligaciones_X_Dependencias
    {
        public ReporteResumenAnualPagoObligaciones_X_Dependencias(int anio, TipoEstudio tipoEstudio,
            IEnumerable<ResumenAnualPagoDeObligaciones_X_DependenciaDTO> resumen_x_dependencias)
        {
            this.anio = anio;
            this.tipoEstudio = tipoEstudio;
            this.resumen_x_dependencias = resumen_x_dependencias;
        }

        public ReporteResumenAnualPagoObligaciones_X_Dependencias()
        {
            resumen_x_dependencias = new List<ResumenAnualPagoDeObligaciones_X_DependenciaDTO>();
        }

        public TipoEstudio tipoEstudio { get; set; }

        public int anio { get; set; }

        public IEnumerable<ResumenAnualPagoDeObligaciones_X_DependenciaDTO> resumen_x_dependencias { get; }

        public decimal TotalEnero
        {
            get
            {
                return resumen_x_dependencias.Sum(x => x.Enero);
            }
        }

        public decimal TotalFebrero
        {
            get
            {
                return resumen_x_dependencias.Sum(x => x.Febrero);
            }
        }

        public decimal TotalMarzo
        {
            get
            {
                return resumen_x_dependencias.Sum(x => x.Marzo);
            }
        }

        public decimal TotalAbril
        {
            get
            {
                return resumen_x_dependencias.Sum(x => x.Abril);
            }
        }

        public decimal TotalMayo
        {
            get
            {
                return resumen_x_dependencias.Sum(x => x.Mayo);
            }
        }

        public decimal TotalJunio
        {
            get
            {
                return resumen_x_dependencias.Sum(x => x.Junio);
            }
        }

        public decimal TotalJulio
        {
            get
            {
                return resumen_x_dependencias.Sum(x => x.Julio);
            }
        }

        public decimal TotalAgosto
        {
            get
            {
                return resumen_x_dependencias.Sum(x => x.Agosto);
            }
        }

        public decimal TotalSetiembre
        {
            get
            {
                return resumen_x_dependencias.Sum(x => x.Setiembre);
            }
        }

        public decimal TotalOctubre
        {
            get
            {
                return resumen_x_dependencias.Sum(x => x.Octubre);
            }
        }

        public decimal TotalNoviembre
        {
            get
            {
                return resumen_x_dependencias.Sum(x => x.Noviembre);
            }
        }

        public decimal TotalDiciembre
        {
            get
            {
                return resumen_x_dependencias.Sum(x => x.Diciembre);
            }
        }

        public decimal TotalGeneral
        {
            get
            {
                return resumen_x_dependencias.Sum(x => 
                    x.Enero + x.Febrero + x.Marzo +
                    x.Abril + x.Mayo + x.Junio +
                    x.Julio + x.Agosto + x.Setiembre +
                    x.Octubre + x.Noviembre + x.Diciembre
                );
            }
        }

        public decimal TotalClasificador(string codDependencia)
        {
            return resumen_x_dependencias
                .Where(x => x.C_CodDependencia.Equals(codDependencia))
                .Sum(x =>
                    x.Enero + x.Febrero + x.Marzo +
                    x.Abril + x.Mayo + x.Junio +
                    x.Julio + x.Agosto + x.Setiembre +
                    x.Octubre + x.Noviembre + x.Diciembre
                );
        }
    }
}
using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebApp.ViewModels
{
    public class ReporteResumenAnualPagoObligaciones_X_Clasificadores
    {
        public ReporteResumenAnualPagoObligaciones_X_Clasificadores(int anio, TipoEstudio tipoEstudio,
            IEnumerable<ResumenAnualPagoOblig_X_Clasificador> resumen_x_clasificadores)
        {
            this.anio = anio;
            this.tipoEstudio = tipoEstudio;
            this.resumen_x_clasificadores = resumen_x_clasificadores;
        }

        public ReporteResumenAnualPagoObligaciones_X_Clasificadores()
        {
            resumen_x_clasificadores = new List<ResumenAnualPagoOblig_X_Clasificador>();
        }

        public TipoEstudio tipoEstudio { get; set; }

        public int anio { get; set; }

        public IEnumerable<ResumenAnualPagoOblig_X_Clasificador> resumen_x_clasificadores { get; }

        public decimal TotalEnero
        {
            get
            {
                return resumen_x_clasificadores.Sum(x => x.Enero);
            }
        }

        public decimal TotalFebrero
        {
            get
            {
                return resumen_x_clasificadores.Sum(x => x.Febrero);
            }
        }

        public decimal TotalMarzo
        {
            get
            {
                return resumen_x_clasificadores.Sum(x => x.Marzo);
            }
        }

        public decimal TotalAbril
        {
            get
            {
                return resumen_x_clasificadores.Sum(x => x.Abril);
            }
        }

        public decimal TotalMayo
        {
            get
            {
                return resumen_x_clasificadores.Sum(x => x.Mayo);
            }
        }

        public decimal TotalJunio
        {
            get
            {
                return resumen_x_clasificadores.Sum(x => x.Junio);
            }
        }

        public decimal TotalJulio
        {
            get
            {
                return resumen_x_clasificadores.Sum(x => x.Julio);
            }
        }

        public decimal TotalAgosto
        {
            get
            {
                return resumen_x_clasificadores.Sum(x => x.Agosto);
            }
        }

        public decimal TotalSetiembre
        {
            get
            {
                return resumen_x_clasificadores.Sum(x => x.Setiembre);
            }
        }

        public decimal TotalOctubre
        {
            get
            {
                return resumen_x_clasificadores.Sum(x => x.Octubre);
            }
        }

        public decimal TotalNoviembre
        {
            get
            {
                return resumen_x_clasificadores.Sum(x => x.Noviembre);
            }
        }

        public decimal TotalDiciembre
        {
            get
            {
                return resumen_x_clasificadores.Sum(x => x.Diciembre);
            }
        }

        public decimal TotalGeneral
        {
            get
            {
                return resumen_x_clasificadores.Sum(x => 
                    x.Enero + x.Febrero + x.Marzo +
                    x.Abril + x.Mayo + x.Junio +
                    x.Julio + x.Agosto + x.Setiembre +
                    x.Octubre + x.Noviembre + x.Diciembre
                );
            }
        }

        public decimal TotalClasificador(string codClasificador)
        {
            return resumen_x_clasificadores
                .Where(x => x.C_CodClasificador.Equals(codClasificador))
                .Sum(x =>
                    x.Enero + x.Febrero + x.Marzo +
                    x.Abril + x.Mayo + x.Junio +
                    x.Julio + x.Agosto + x.Setiembre +
                    x.Octubre + x.Noviembre + x.Diciembre
                );
        }
    }
}
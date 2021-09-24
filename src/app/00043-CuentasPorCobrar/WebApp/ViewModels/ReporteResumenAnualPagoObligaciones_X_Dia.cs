using Domain.Entities;
using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebApp.ViewModels
{
    public class ReporteResumenAnualPagoObligaciones_X_Dia
    {
        public ReporteResumenAnualPagoObligaciones_X_Dia(int anio, string nombreEntidadFinanc, string numCuenta,
            IEnumerable<ResumenAnualPagoDeObligaciones_X_DiaDTO> resumen_x_dia)
        {
            this.anio = anio;
            this.nombreEntidadFinanc = nombreEntidadFinanc;
            this.numCuenta = numCuenta;
            this.resumen_x_dia = resumen_x_dia;

            FechaActual = DateTime.Now.ToString(FormatosDateTime.BASIC_DATE);
            HoraActual = DateTime.Now.ToString(FormatosDateTime.BASIC_TIME);
        }

        public ReporteResumenAnualPagoObligaciones_X_Dia()
        {
            resumen_x_dia = new List<ResumenAnualPagoDeObligaciones_X_DiaDTO>();

            FechaActual = DateTime.Now.ToString(FormatosDateTime.BASIC_DATE);
            HoraActual = DateTime.Now.ToString(FormatosDateTime.BASIC_TIME);
        }


        public int anio { get; set; }

        public string nombreEntidadFinanc { get; set; }

        public string numCuenta { get; set; }


        public IEnumerable<ResumenAnualPagoDeObligaciones_X_DiaDTO> resumen_x_dia { get; }

        public decimal TotalEnero
        {
            get
            {
                return resumen_x_dia.Sum(x => x.Enero);
            }
        }

        public string T_TotalEnero
        {
            get
            {
                return TotalEnero.ToString(FormatosDecimal.BASIC_DECIMAL);
            }
        }

        public decimal TotalFebrero
        {
            get
            {
                return resumen_x_dia.Sum(x => x.Febrero);
            }
        }

        public string T_TotalFebrero
        {
            get
            {
                return TotalFebrero.ToString(FormatosDecimal.BASIC_DECIMAL);
            }
        }

        public decimal TotalMarzo
        {
            get
            {
                return resumen_x_dia.Sum(x => x.Marzo);
            }
        }

        public string T_TotalMarzo
        {
            get
            {
                return TotalMarzo.ToString(FormatosDecimal.BASIC_DECIMAL);
            }
        }

        public decimal TotalAbril
        {
            get
            {
                return resumen_x_dia.Sum(x => x.Abril);
            }
        }

        public string T_TotalAbril
        {
            get
            {
                return TotalAbril.ToString(FormatosDecimal.BASIC_DECIMAL);
            }
        }

        public decimal TotalMayo
        {
            get
            {
                return resumen_x_dia.Sum(x => x.Mayo);
            }
        }

        public string T_TotalMayo
        {
            get
            {
                return TotalMayo.ToString(FormatosDecimal.BASIC_DECIMAL);
            }
        }

        public decimal TotalJunio
        {
            get
            {
                return resumen_x_dia.Sum(x => x.Junio);
            }
        }

        public string T_TotalJunio
        {
            get
            {
                return TotalJunio.ToString(FormatosDecimal.BASIC_DECIMAL);
            }
        }

        public decimal TotalJulio
        {
            get
            {
                return resumen_x_dia.Sum(x => x.Julio);
            }
        }

        public string T_TotalJulio
        {
            get
            {
                return TotalJulio.ToString(FormatosDecimal.BASIC_DECIMAL);
            }
        }

        public decimal TotalAgosto
        {
            get
            {
                return resumen_x_dia.Sum(x => x.Agosto);
            }
        }

        public string T_TotalAgosto
        {
            get
            {
                return TotalAgosto.ToString(FormatosDecimal.BASIC_DECIMAL);
            }
        }

        public decimal TotalSetiembre
        {
            get
            {
                return resumen_x_dia.Sum(x => x.Setiembre);
            }
        }

        public string T_TotalSetiembre
        {
            get
            {
                return TotalSetiembre.ToString(FormatosDecimal.BASIC_DECIMAL);
            }
        }

        public decimal TotalOctubre
        {
            get
            {
                return resumen_x_dia.Sum(x => x.Octubre);
            }
        }

        public string T_TotalOctubre
        {
            get
            {
                return TotalOctubre.ToString(FormatosDecimal.BASIC_DECIMAL);
            }
        }

        public decimal TotalNoviembre
        {
            get
            {
                return resumen_x_dia.Sum(x => x.Noviembre);
            }
        }

        public string T_TotalNoviembre
        {
            get
            {
                return TotalNoviembre.ToString(FormatosDecimal.BASIC_DECIMAL);
            }
        }

        public decimal TotalDiciembre
        {
            get
            {
                return resumen_x_dia.Sum(x => x.Diciembre);
            }
        }

        public string T_TotalDiciembre
        {
            get
            {
                return TotalDiciembre.ToString(FormatosDecimal.BASIC_DECIMAL);
            }
        }

        public decimal TotalGeneral
        {
            get
            {
                return resumen_x_dia.Sum(x => 
                    x.Enero + x.Febrero + x.Marzo +
                    x.Abril + x.Mayo + x.Junio +
                    x.Julio + x.Agosto + x.Setiembre +
                    x.Octubre + x.Noviembre + x.Diciembre
                );
            }
        }

        public string T_TotalGeneral
        {
            get
            {
                return TotalGeneral.ToString(FormatosDecimal.BASIC_DECIMAL);
            }
        }

        public string FechaActual { get; }

        public string HoraActual { get; }

        public decimal TotalDia(int I_Dia)
        {
            return resumen_x_dia
                .Where(x => x.I_Dia == I_Dia)
                .Sum(x =>
                    x.Enero + x.Febrero + x.Marzo +
                    x.Abril + x.Mayo + x.Junio +
                    x.Julio + x.Agosto + x.Setiembre +
                    x.Octubre + x.Noviembre + x.Diciembre
                );
        }

        public string T_TotalDia(int I_Dia)
        {
            return TotalDia(I_Dia).ToString(FormatosDecimal.BASIC_DECIMAL);
        }
    }
}
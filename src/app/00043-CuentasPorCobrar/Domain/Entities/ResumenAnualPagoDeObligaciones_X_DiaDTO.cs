using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities
{
    public class ResumenAnualPagoDeObligaciones_X_DiaDTO
    {
        public int I_Dia { get; set; }
        public decimal Enero { get; set; }
        public decimal Febrero { get; set; }
        public decimal Marzo { get; set; }
        public decimal Abril { get; set; }
        public decimal Mayo { get; set; }
        public decimal Junio { get; set; }
        public decimal Julio { get; set; }
        public decimal Agosto { get; set; }
        public decimal Setiembre { get; set; }
        public decimal Octubre { get; set; }
        public decimal Noviembre { get; set; }
        public decimal Diciembre { get; set; }

        public string T_Enero
        {
            get
            {
                return Enero.ToString(FormatosDecimal.BASIC_DECIMAL);
            }
        }

        public string T_Febrero
        {
            get
            {
                return Febrero.ToString(FormatosDecimal.BASIC_DECIMAL);
            }
        }

        public string T_Marzo
        {
            get
            {
                return Marzo.ToString(FormatosDecimal.BASIC_DECIMAL);
            }
        }

        public string T_Abril
        {
            get
            {
                return Abril.ToString(FormatosDecimal.BASIC_DECIMAL);
            }
        }

        public string T_Mayo
        {
            get
            {
                return Mayo.ToString(FormatosDecimal.BASIC_DECIMAL);
            }
        }

        public string T_Junio
        {
            get
            {
                return Junio.ToString(FormatosDecimal.BASIC_DECIMAL);
            }
        }

        public string T_Julio
        {
            get
            {
                return Julio.ToString(FormatosDecimal.BASIC_DECIMAL);
            }
        }

        public string T_Agosto
        {
            get
            {
                return Agosto.ToString(FormatosDecimal.BASIC_DECIMAL);
            }
        }

        public string T_Setiembre
        {
            get
            {
                return Setiembre.ToString(FormatosDecimal.BASIC_DECIMAL);
            }
        }

        public string T_Octubre
        {
            get
            {
                return Octubre.ToString(FormatosDecimal.BASIC_DECIMAL);
            }
        }

        public string T_Noviembre
        {
            get
            {
                return Noviembre.ToString(FormatosDecimal.BASIC_DECIMAL);
            }
        }

        public string T_Diciembre
        {
            get
            {
                return Diciembre.ToString(FormatosDecimal.BASIC_DECIMAL);
            }
        }
    }
}

using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities
{
    public class CantidadDePagosRegistrados_X_DiaDTO
    {
        public int I_Dia { get; set; }
        public int Enero { get; set; }
        public int Febrero { get; set; }
        public int Marzo { get; set; }
        public int Abril { get; set; }
        public int Mayo { get; set; }
        public int Junio { get; set; }
        public int Julio { get; set; }
        public int Agosto { get; set; }
        public int Setiembre { get; set; }
        public int Octubre { get; set; }
        public int Noviembre { get; set; }
        public int Diciembre { get; set; }

        public string T_Enero
        {
            get
            {
                return Enero.ToString();
            }
        }

        public string T_Febrero
        {
            get
            {
                return Febrero.ToString();
            }
        }

        public string T_Marzo
        {
            get
            {
                return Marzo.ToString();
            }
        }

        public string T_Abril
        {
            get
            {
                return Abril.ToString();
            }
        }

        public string T_Mayo
        {
            get
            {
                return Mayo.ToString();
            }
        }

        public string T_Junio
        {
            get
            {
                return Junio.ToString();
            }
        }

        public string T_Julio
        {
            get
            {
                return Julio.ToString();
            }
        }

        public string T_Agosto
        {
            get
            {
                return Agosto.ToString();
            }
        }

        public string T_Setiembre
        {
            get
            {
                return Setiembre.ToString();
            }
        }

        public string T_Octubre
        {
            get
            {
                return Octubre.ToString();
            }
        }

        public string T_Noviembre
        {
            get
            {
                return Noviembre.ToString();
            }
        }

        public string T_Diciembre
        {
            get
            {
                return Diciembre.ToString();
            }
        }
    }
}

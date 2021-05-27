using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebApp.ViewModels
{
    public class DevolucionesViewModel
    {
        public string NroRecibo { get; set; }
        public string EntidadFinanciera { get; set; }
        public DateTime FecRegistro { get; set; }
        public string Concepto{ get; set; }
    }

    public class DevolucionRegistroViewModel
    {

    }

}
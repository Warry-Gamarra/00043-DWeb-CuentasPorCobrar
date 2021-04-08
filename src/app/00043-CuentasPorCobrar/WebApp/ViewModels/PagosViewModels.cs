using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebApp.ViewModels
{
    public class CargarArchivoViewModel
    {
        public int EntidadFinanciera { get; set; }
        public bool InfoInFile { get; set; }
        public int Anio { get; set; }
        public int Periodo { get; set; }
    }
}
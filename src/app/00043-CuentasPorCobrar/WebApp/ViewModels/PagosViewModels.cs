using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebApp.ViewModels
{
    public class CargarArchivoViewModel
    {
        public TipoPago TipoArchivo { get; set; }
        public int EntidadFinanciera { get; set; }
        public bool InfoInFile { get; set; }
        public int Anio { get; set; }
        public int Periodo { get; set; }
    }


    public class ArchivoImportadoViewModel
    {
        public TipoPago TipoArchivo { get; set; }
        public int EntidadFinanciera { get; set; }
        public string FileName { get; set; }
        public string UrlFile { get; set; }
        public DateTime FecCarga{ get; set; }
        public decimal FileSize { get; set; }
    }
}
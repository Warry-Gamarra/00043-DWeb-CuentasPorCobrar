using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebApp.Models
{
    public class PagoConstanciaModel
    {
        public int pagoBancoID { get; set; }

        public int? anioConstancia { get; set; }

        public int? nroConstancia { get; set; }
    }
}
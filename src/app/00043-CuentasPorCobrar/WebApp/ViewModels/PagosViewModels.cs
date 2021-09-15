using Domain.Entities;
using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace WebApp.ViewModels
{
    public class DatosPagoViewModel
    {
        public int PagoId { get; set; }
        public string CodOperacion { get; set; }

        [Display(Name = "Entidad recaudadora ")]
        public int EntidadRecaudadoraId { get; set; }

        public string EntidadRecaudadora { get; set; }

        [Display(Name = "Concepto ")]
        public string Concepto { get; set; }

        [Display(Name = "Lugar de pago")]
        public string LugarPago { get; set; }

        [Display(Name = "Fecha de pago")]
        public DateTime FecPago { get; set; }

        [Display(Name = "Monto")]
        public decimal MontoPago { get; set; }

        [Display(Name = "Nro SIAF")]
        public int? NroSIAF { get; set; }

        public DatosPagoViewModel() { }

        public DatosPagoViewModel(PagoEntity pagoEntity)
        {
            this.PagoId = pagoEntity.PagoProcesId;
            this.CodOperacion = pagoEntity.CodOperacion;
            this.EntidadRecaudadoraId = pagoEntity.EntidadRecaudaID;
            this.EntidadRecaudadora = pagoEntity.EntidadRecaudaDesc;
            this.Concepto = pagoEntity.ConceptoPagoDesc;
            this.LugarPago = pagoEntity.LugarPago;
            this.FecPago = pagoEntity.FecPago;
            this.MontoPago = pagoEntity.MontoPago;
            this.NroSIAF = pagoEntity.NroSIAF;
        }
    }
}
using Domain.Entities;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace WebApp.ViewModels
{
    public class DevolucionesViewModel
    {
        public int? DevolucionId { get; set; }
        public string NroRecibo { get; set; }
        public string EntidadRecaudadora { get; set; }
        public DateTime? FecRegistro { get; set; }
        public decimal Monto { get; set; }
        public string Concepto { get; set; }

        public DevolucionesViewModel() { }

        public DevolucionesViewModel(DevolucionPago devolucionPago)
        {
            this.DevolucionId = devolucionPago.DevolucionId;
            this.EntidadRecaudadora = devolucionPago.EntidadRecaudadoraDesc;
            this.Concepto = devolucionPago.ConceptoPago;
            this.NroRecibo = devolucionPago.ReferenciaPago;
            this.Monto = devolucionPago.MontoDevolucion;
            this.FecRegistro = devolucionPago.FecAprueba;
        }
    }

    public class RegistrarDevolucionPagoViewModel
    {
        public int? DevolucionId { get; set; }

        [Display(Name = "Entidad recaudadora")]
        [Required]
        public int EntidadRecaudadora { get; set; }

        [Required]
        public int PagoReferenciaId { get; set; }

        [Display(Name = "Referencia de pago (Nro liquidación)")]
        [Required]
        public string ReferenciaPago { get; set; }

        [Display(Name = "Fecha de pago")]
        [Required]
        public DateTime? FecPagoRef { get; set; }

        [Display(Name = "Monto Devolución")]
        [Required]
        public decimal MontoDevolucion { get; set; }

        [Display(Name = "Fecha de aprobación")]
        [Required]
        public DateTime? FecAprueba { get; set; }

        [Display(Name = "Fecha de devolución")]
        public DateTime? FecDevuelve { get; set; }

        [Display(Name = "Nro SIAF")]
        public int NroSIAF { get; set; }

        public RegistrarDevolucionPagoViewModel() { }

        public RegistrarDevolucionPagoViewModel(DevolucionPago devolucionPago)
        {
            this.DevolucionId = devolucionPago.DevolucionId;
            this.EntidadRecaudadora = devolucionPago.EntidadRecaudadoraId;
            this.PagoReferenciaId = devolucionPago.PagoReferenciaId;
            this.ReferenciaPago = devolucionPago.ReferenciaPago;
            this.FecPagoRef = devolucionPago.FecPagoRef;
            this.MontoDevolucion = devolucionPago.MontoDevolucion;
            this.FecAprueba = devolucionPago.FecAprueba;
            this.FecDevuelve = devolucionPago.FecDevuelve;
        }

    }
}
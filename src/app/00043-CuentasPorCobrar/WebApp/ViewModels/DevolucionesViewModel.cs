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
        public DateTime? FecAprobacion { get; set; }
        public decimal Monto { get; set; }
        public string Concepto { get; set; }
        public bool Anulado { get; set; }

        public DevolucionesViewModel() { }

        public DevolucionesViewModel(DevolucionPago devolucionPago)
        {
            this.DevolucionId = devolucionPago.DevolucionId;
            this.EntidadRecaudadora = devolucionPago.EntidadRecaudadoraDesc;
            this.Concepto = devolucionPago.ConceptoPago;
            this.NroRecibo = devolucionPago.ReferenciaPago;
            this.Monto = devolucionPago.MontoDevolucion;
            this.FecAprobacion = devolucionPago.FecAprueba;
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

        [Display(Name = "Referencia de pago")]
        [Required]
        public string ReferenciaPago { get; set; }

        public DatosPagoViewModel DatosPago { get; set; }

        [Required]
        public int? PagoRefId { get; set; }

        [Required]
        public DateTime? FecPagoRef { get; set; }

        [Display(Name = "Total descuentos")]
        [Required]
        public decimal MontoDescuento { get; set; }

        [Display(Name = "Total a devolver")]
        [Required]
        public decimal MontoDevolucion { get; set; }

        [Display(Name = "Fec. Aprobación")]
        [Required]
        public DateTime? FecAprueba { get; set; }

        [Display(Name = "Fec. Devolución")]
        public DateTime? FecDevuelve { get; set; }

        [Display(Name = "Comentarios")]
        public string Comentario { get; set; }

        public RegistrarDevolucionPagoViewModel()
        {
            this.DatosPago = new DatosPagoViewModel();
        }

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
            this.Comentario = devolucionPago.Comentario;
            this.DatosPago = new DatosPagoViewModel();
        }

    }
}
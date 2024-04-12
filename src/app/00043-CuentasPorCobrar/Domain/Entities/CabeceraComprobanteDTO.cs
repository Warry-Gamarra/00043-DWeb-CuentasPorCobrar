using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities
{
    public class CabeceraComprobanteDTO
    {
        public CabeceraComprobanteDTO(IEnumerable<ComprobantePagoDTO> comprobantePagoDTO)
        {
            tipoComprobanteCod = comprobantePagoDTO.First().tipoComprobanteCod;

            inicialTipoComprobante = comprobantePagoDTO.First().inicial;

            numeroSerie = inicialTipoComprobante.Length > 0 ? comprobantePagoDTO.First().numeroSerie.Value.ToString("D" + (4 - inicialTipoComprobante.Length)) : comprobantePagoDTO.First().numeroSerie.Value.ToString("D4");

            numeroComprobante = comprobantePagoDTO.First().numeroComprobante.Value.ToString("D8");

            fechaEmision = comprobantePagoDTO.First().fechaEmision.Value;

            tipoPago = comprobantePagoDTO.First().tipoPago;

            if (tipoComprobanteCod == CodigoTipoComprobante.FACTURA)
            {
                tipoRutReceptor = "6";
                rutReceptor = comprobantePagoDTO.First().ruc;
                dirReceptor = comprobantePagoDTO.First().direccion;
            }
            else
            {
                tipoRutReceptor = "1";
                rutReceptor = comprobantePagoDTO.First().codDepositante == null || comprobantePagoDTO.First().codDepositante.Length == 0 ? "-" : comprobantePagoDTO.First().codDepositante;
                dirReceptor = String.IsNullOrEmpty(comprobantePagoDTO.First().direccion) ? "-" : comprobantePagoDTO.First().direccion;
            }

            nomDepositante = comprobantePagoDTO.First().nomDepositante == null || comprobantePagoDTO.First().nomDepositante.Length == 0 ? "No Definido" : comprobantePagoDTO.First().nomDepositante;

            esGravado = comprobantePagoDTO.First().esGravado.Value;

            igv = esGravado ? Digiflow.IGV : 0;

            items = new List<DetalleComprobanteDTO>();

            foreach (var item in comprobantePagoDTO)
            {
                var detalle = new DetalleComprobanteDTO(item.concepto, item.cantidad, item.montoPagado, item.interesMoratorio, igv, item.codTasa);

                items.Add(detalle);
            }

            codigoImpuesto = esGravado ? "1000" : "9998";

            fecPago = comprobantePagoDTO.First().fecPago;

            codigoTipoAfectacion = esGravado ? "10" : "30";

            codOperacion = comprobantePagoDTO.First().codOperacion;

            entidadFinanID = comprobantePagoDTO.First().entidadFinanID;

            entidadDesc = comprobantePagoDTO.First().entidadDesc;

            numeroCuenta = comprobantePagoDTO.First().numeroCuenta;

            codigoInterno = comprobantePagoDTO.First().entidadFinanID == Bancos.BCP_ID ? comprobantePagoDTO.First().codigoInterno : "-";

            nombreArchivo = String.Format("{0}-{1}-{2}{3}.txt", Digiflow.RUC_UNFV, numeroSerie, inicialTipoComprobante, numeroComprobante);
        }

        public string tipoComprobanteCod { get; set; }

        public string inicialTipoComprobante { get; }

        public string numeroSerie { get; }

        public string numeroComprobante { get; }

        public DateTime fechaEmision { get; }

        public string tipoRutReceptor { get; }

        public string rutReceptor { get; }

        public string nomDepositante { get; }

        public string dirReceptor { get; }

        public bool esGravado { get; }

        public decimal igv { get; }

        public decimal montoNeto 
        {
            get
            {
                return items.Sum(x => x.montoUnitarioTotal);
            }
        }

        public decimal mntExe
        {
            get
            {
                return esGravado ? 0 : montoNeto;
            }
        }

        public decimal montoIGV
        {
            get
            {
                return items.Sum(x => x.montoIGVTotal);
            }
        }

        public decimal montoPagado
        {
            get
            {
                return items.Sum(x => x.montoTotal);
            }
        }

        public string codigoImpuesto { get; }

        public string codigoTipoAfectacion { get; }

        public DateTime fecPago { get; }

        public string codOperacion { get; }

        public int entidadFinanID { get; }

        public string entidadDesc { get; }

        public string numeroCuenta { get; }

        public string codigoInterno { get; }

        public List<DetalleComprobanteDTO> items { get; }

        public string nombreArchivo { get; }

        public TipoPago tipoPago { get; set; }
    }
}

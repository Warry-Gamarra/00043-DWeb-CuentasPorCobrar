using Data.Tables;
using Data.Views;
using Domain.Helpers;
using Domain.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities
{
    public class DevolucionPago : IDevolucionPago
    {
        public int? DevolucionId { get; set; }
        public int EntidadRecaudadoraId { get; set; }
        public string EntidadRecaudadoraDesc { get; set; }
        public int PagoReferenciaId { get; set; }
        public string ReferenciaPago { get; set; }
        public string ConceptoPago { get; set; }
        public string Clasificador { get; set; }
        public DateTime FecPagoRef { get; set; }
        public decimal MontoDevolucion { get; set; }
        public DateTime? FecAprueba { get; set; }
        public DateTime? FecDevuelve { get; set; }
        public string NroSIAF { get; set; }
        public string Comentario { get; set; }


        private readonly TR_DevolucionPago _devolucionPagoRepository;

        public DevolucionPago()
        {
            _devolucionPagoRepository = new TR_DevolucionPago();
        }

        public DevolucionPago(VW_DevolucionPago table)
        {
            this.DevolucionId = table.I_DevolucionPagoID;
            this.PagoReferenciaId = table.I_PagoProcesID;
            this.ReferenciaPago = table.C_CodOperacion;
            this.Clasificador = table.C_CodClasificador;
            this.ConceptoPago = table.T_ConceptoPagoDesc;
            this.MontoDevolucion = table.I_MontoPagoDev;
            this.FecAprueba = table.D_FecDevAprob.Value;
            this.FecDevuelve = table.D_FecDevPago;
            this.FecPagoRef = table.D_FecProc.Value;
        }


        public List<DevolucionPago> Find()
        {
            List<DevolucionPago> result = new List<DevolucionPago>();

            foreach (var item in VW_DevolucionPago.Find())
            {
                result.Add(new DevolucionPago(item));
            }

            return result;
        }

        public DevolucionPago Find(int devolucionId)
        {
            DevolucionPago result = new DevolucionPago(VW_DevolucionPago.Find(devolucionId));

            return result;
        }

        public Response AnularDevolucion(int pagoProcesadoId, int currentUserId)
        {
            _devolucionPagoRepository.I_PagoProcesID = pagoProcesadoId;
            _devolucionPagoRepository.D_FecMod = DateTime.Now;

            var result = new Response(_devolucionPagoRepository.AnularDevolcionPago(currentUserId));

            return result;
        }

        public Response Save(DevolucionPago devolucionPago, int currentUserId, SaveOption saveOption)
        {
            _devolucionPagoRepository.I_DevolucionPagoID = devolucionPago.DevolucionId ?? 0;
            _devolucionPagoRepository.I_MontoPagoDev = devolucionPago.MontoDevolucion;
            _devolucionPagoRepository.D_FecDevAprob = devolucionPago.FecAprueba;
            _devolucionPagoRepository.D_FecDevPago = devolucionPago.FecDevuelve;

            switch (saveOption)
            {
                case SaveOption.Insert:
                    _devolucionPagoRepository.I_PagoProcesID = devolucionPago.PagoReferenciaId;
                    _devolucionPagoRepository.D_FecProc = devolucionPago.FecPagoRef;
                    _devolucionPagoRepository.D_FecCre = DateTime.Now;
                    return new Response(_devolucionPagoRepository.Insert(currentUserId));

                case SaveOption.Update:
                    _devolucionPagoRepository.D_FecMod = DateTime.Now;
                    return new Response(_devolucionPagoRepository.Update(currentUserId));
            }

            return new Response()
            {
                Value = false,
                Message = "Operación Inválida."
            };
        }
    }
}

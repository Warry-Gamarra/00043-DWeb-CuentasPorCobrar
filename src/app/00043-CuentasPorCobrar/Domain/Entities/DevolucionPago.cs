using Data.Tables;
using Domain.Helpers;
using Domain.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities
{
    public class DevolucionPago: IDevolucionPago
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


        private readonly TR_DevolucionPago _devolucionPagoRepository;

        public DevolucionPago() {
            _devolucionPagoRepository = new TR_DevolucionPago();
        }

        public DevolucionPago(TR_DevolucionPago table)
        {
            this.DevolucionId = table.I_DevolucionPagoID;
            this.PagoReferenciaId = table.I_PagoProcesID;
            this.MontoDevolucion = table.I_MontoPagoDev;
            this.FecAprueba = table.D_FecDevAprob.Value;
            this.FecDevuelve = table.D_FecDevPago;
            this.FecPagoRef = table.D_FecProc.Value;
        }


        public Response ChangeState(int devolucionPagoId, bool currentState, int currentUserId)
        {
            throw new NotImplementedException();
        }

        public List<DevolucionPago> Find()
        {
            List<DevolucionPago> result = new List<DevolucionPago>();

            foreach (var item in _devolucionPagoRepository.Find())
            {
                result.Add(new DevolucionPago(item));
            }

            return result;
        }

        public DevolucionPago Find(int devolucionPagoId)
        {
            throw new NotImplementedException();
        }

        public Response Save(DevolucionPago devolucionPago, int currentUserId, SaveOption saveOption)
        {
            throw new NotImplementedException();
        }
    }
}

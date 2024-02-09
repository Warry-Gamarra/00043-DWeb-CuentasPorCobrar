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
        public int PagoBancoID { get; set; }
        public string CodOperacionPago { get; set; }
        public string ReferenciaBCP { get; set; }
        public string ConceptoPago { get; set; }
        public DateTime FecPagoRef { get; set; }
        public decimal MontoDevolucion { get; set; }
        public decimal MontoPagado { get; set; }
        public DateTime? FecAprueba { get; set; }
        public DateTime? FecDevuelve { get; set; }
        public string Comentario { get; set; }

        private readonly TR_DevolucionPago _devolucionPagoRepository;

        public DevolucionPago()
        {
            _devolucionPagoRepository = new TR_DevolucionPago();
        }

        public DevolucionPago(VW_DevolucionPago table)
        {
            this.DevolucionId = table.I_DevolucionPagoID;
            this.PagoBancoID = table.I_PagoBancoID;
            this.CodOperacionPago = table.C_CodOperacion;
            this.ReferenciaBCP = table.C_ReferenciaBCP;
            this.ConceptoPago = table.T_ConceptoPagoDesc;
            this.MontoDevolucion = table.I_MontoPagoDev;
            this.MontoPagado = table.I_MontoPago;
            this.FecAprueba = table.D_FecDevAprob.Value;
            this.FecDevuelve = table.D_FecDevPago;
            this.FecPagoRef = table.D_FecProc.Value;
            this.Comentario = table.T_Comentario;
            this.EntidadRecaudadoraDesc = table.T_EntidadDesc;
            this.EntidadRecaudadoraId = table.I_EntidadFinanID;
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

        public Response AnularDevolucion(int devolucionPagoId, int currentUserId)
        {
            _devolucionPagoRepository.I_DevolucionPagoID = devolucionPagoId;
            _devolucionPagoRepository.D_FecMod = DateTime.Now;

            var result = new Response(_devolucionPagoRepository.AnularDevolcionPago(currentUserId));

            return result;
        }

        public Response Save(DevolucionPago devolucionPago, int currentUserId, SaveOption saveOption)
        {
            _devolucionPagoRepository.I_MontoPagoDev = devolucionPago.MontoDevolucion;
            _devolucionPagoRepository.D_FecDevAprob = devolucionPago.FecAprueba;
            _devolucionPagoRepository.D_FecDevPago = devolucionPago.FecDevuelve;
            _devolucionPagoRepository.T_Comentario = devolucionPago.Comentario;

            switch (saveOption)
            {
                case SaveOption.Insert:
                    _devolucionPagoRepository.I_PagoBancoID = devolucionPago.PagoBancoID;
                    _devolucionPagoRepository.D_FecProc = devolucionPago.FecPagoRef;
                    _devolucionPagoRepository.D_FecCre = DateTime.Now;
                    return new Response(_devolucionPagoRepository.Insert(currentUserId));

                case SaveOption.Update:
                    _devolucionPagoRepository.I_DevolucionPagoID = devolucionPago.DevolucionId.Value;
                    _devolucionPagoRepository.D_FecMod = DateTime.Now;
                    return new Response(_devolucionPagoRepository.Update(currentUserId));
            }

            return new Response()
            {
                Value = false,
                Message = "Operación Inválida."
            };
        }

        public bool ExisteDevolucion(int pagoBancoID)
        {
            try
            {
                return _devolucionPagoRepository.ExisteDevolucion(pagoBancoID);
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
    }
}

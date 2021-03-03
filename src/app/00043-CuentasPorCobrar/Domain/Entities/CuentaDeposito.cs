using Data.Tables;
using Domain.DTO;
using Domain.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities
{
    public class CuentaDeposito: ICuentaDeposito
    {
        public int I_CtaDepID { get; set; }
        public string T_DescCuenta { get; set; }
        public string C_NumeroCuenta { get; set; }
        public int I_EntidadFinanId { get; set; }
        public string T_EntidadDesc { get; set; }
        public string T_Observacion { get; set; }
        public bool Habilitado { get; set; }

        public DateTime? FechaActualiza { get; set; }
        public Response Response { get; set; }


        private readonly TC_CuentaDeposito _ctaDepRepository;

        public CuentaDeposito()
        {
            _ctaDepRepository = new TC_CuentaDeposito();
            this.Response = new Response() { Value = true };
        }

        public CuentaDeposito(TC_CuentaDeposito table)
        {
            this.I_CtaDepID = table.I_CtaDepositoID;
            this.T_DescCuenta = table.T_DescCuenta;
            this.C_NumeroCuenta = table.C_NumeroCuenta;
            this.I_EntidadFinanId = table.I_EntidadFinanID;
            this.T_EntidadDesc = table.T_EntidadDesc;
            this.T_Observacion = table.T_Observacion;
            this.Habilitado = table.B_Habilitado;
            this.FechaActualiza = table.D_FecMod.HasValue ? table.D_FecMod.Value : table.D_FecCre;
            this.Response = new Response() { Value = true };
        }

        
        public Response ChangeState(int ctaDepositoId, bool currentState, int currentUserId)
        {
            _ctaDepRepository.I_CtaDepositoID = ctaDepositoId;
            _ctaDepRepository.D_FecMod = DateTime.Now;
            _ctaDepRepository.B_Habilitado = !currentState;

            return new Response(_ctaDepRepository.ChangeState(currentUserId));
        }

        public List<CuentaDeposito> Find()
        {
            var result = new List<CuentaDeposito>();
            foreach (var item in _ctaDepRepository.Find())
            {
                result.Add(new CuentaDeposito(item));
            }

            return result;
        }

        public CuentaDeposito Find(int ctaDepositoId)
        {
            TC_CuentaDeposito data = _ctaDepRepository.Find(ctaDepositoId);
            if (data != null)
            {
                return new CuentaDeposito(data);
            }
            return new CuentaDeposito()
            {
                Response = new Response()
                {
                    Value = false,
                    Message = "No se encontraron resultados para el identificador de la cuenta"
                }
            };
        }

        public Response Save(CuentaDeposito cuentaDeposito, int currentUserId, SaveOption saveOption)
        {
            _ctaDepRepository.I_CtaDepositoID = cuentaDeposito.I_CtaDepID;
            _ctaDepRepository.I_EntidadFinanID = cuentaDeposito.I_EntidadFinanId;
            _ctaDepRepository.T_DescCuenta = cuentaDeposito.T_DescCuenta;
            _ctaDepRepository.C_NumeroCuenta = cuentaDeposito.C_NumeroCuenta;
            _ctaDepRepository.T_Observacion = cuentaDeposito.T_Observacion;
            _ctaDepRepository.B_Habilitado = cuentaDeposito.Habilitado;

            switch (saveOption)
            {
                case SaveOption.Insert:
                    _ctaDepRepository.D_FecCre = DateTime.Now;
                    return new Response(_ctaDepRepository.Insert(currentUserId));

                case SaveOption.Update:
                    _ctaDepRepository.D_FecMod = DateTime.Now;
                    return new Response(_ctaDepRepository.Update(currentUserId));
            }

            return new Response()
            {
                Value = false,
                Message = "Operación Inváiida."
            };
        }
    }
}

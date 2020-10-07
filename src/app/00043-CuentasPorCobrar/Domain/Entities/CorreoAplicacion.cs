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
    public class CorreoAplicacion : ICorreoAplicacion
    {
        public int Id { get; set; }
        public string Address { get; set; }
        public string Password { get; set; }
        public string SecurityType { get; set; }
        public string HostName { get; set; }
        public int Port { get; set; }
        public bool Enabled { get; set; }
        public DateTime FecUpdated { get; set; }
        public Response Response { get; set; }

        private readonly TS_CorreoAplicacion _correoRepository;
        public CorreoAplicacion()
        {
            _correoRepository = new TS_CorreoAplicacion();
        }

        public CorreoAplicacion(TS_CorreoAplicacion table)
        {
            this.Id = table.I_CorreoID;
            this.Address = table.T_DireccionCorreo;
            this.Password = table.T_PasswordCorreo;
            this.SecurityType = table.T_PasswordCorreo;
            this.HostName = table.T_PasswordCorreo;
            this.Port = table.I_Puerto;
            this.Enabled = table.B_Habilitado;
            this.FecUpdated = table.D_FecUpdate;
            this.Response = new Response() { Value = true };
        }



        public Response ChangeState(int corcorreoAplicacionId, bool currentState, int currentUserId)
        {
            throw new NotImplementedException();
        }

        public List<CorreoAplicacion> Find()
        {
            var result = new List<CorreoAplicacion>();
            foreach (var item in _correoRepository.Find())
            {
                result.Add(new CorreoAplicacion(item));
            }

            return result;
        }

        public CorreoAplicacion Find(int correoAplicacionId)
        {
            var data = _correoRepository.Find(correoAplicacionId);
            if (data != null)
            {
                return new CorreoAplicacion(data);
            }
            return new CorreoAplicacion()
            {
                Response = new Response()
                {
                    Value = false,
                    Message = "No se encontraron resultados para el identificador de correo"
                }
            };
        }

        public Response Save(CorreoAplicacion correoAplicacion, int currentUserId, SaveOption saveOption)
        {
            _correoRepository.I_CorreoID = correoAplicacion.Id;
            _correoRepository.T_DireccionCorreo = correoAplicacion.Address;
            _correoRepository.T_PasswordCorreo = correoAplicacion.Password;
            _correoRepository.T_HostName = correoAplicacion.HostName;
            _correoRepository.T_Seguridad = correoAplicacion.SecurityType;
            _correoRepository.I_Puerto = correoAplicacion.Port;
            _correoRepository.D_FecUpdate = DateTime.Now;

            switch (saveOption)
            {
                case SaveOption.Insert:
                    return new Response(_correoRepository.Insert(currentUserId));
                case SaveOption.Update:
                    return new Response(_correoRepository.Update(currentUserId));
            }

            return new Response()
            {
                Value = false,
                Message = "Operación Inváiida."
            };
        }
    }
}

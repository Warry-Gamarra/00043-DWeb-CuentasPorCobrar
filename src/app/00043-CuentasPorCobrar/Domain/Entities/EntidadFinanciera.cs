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
    public class EntidadFinanciera : IEntidadFinanciera
    {
        public int Id { get; set; }
        public string Nombre { get; set; }
        public bool Habilitado { get; set; }
        public DateTime? FechaActualiza { get; set; }
        public Response Response { get; set; }



        private readonly TC_EntidadFinanciera _entFinanRepository;

        public EntidadFinanciera()
        {
            _entFinanRepository = new TC_EntidadFinanciera();
            this.Response = new Response() { Value = true };
        }

        public EntidadFinanciera(TC_EntidadFinanciera table)
        {
            this.Id = table.I_EntidadFinanID;
            this.Nombre = table.T_EntidadDesc;
            this.Habilitado = table.B_Habilitado;
            this.FechaActualiza = table.D_FecMod.HasValue ? table.D_FecMod.Value : table.D_FecCre.Value;
            this.Response = new Response() { Value = true };
        }



        public Response ChangeState(int entidadFinanId, bool currentState, int currentUserId)
        {
            _entFinanRepository.I_EntidadFinanID = entidadFinanId;
            _entFinanRepository.D_FecMod = DateTime.Now;
            _entFinanRepository.B_Habilitado = !currentState;

            return new Response(_entFinanRepository.ChangeState(currentUserId));
        }

        public List<EntidadFinanciera> Find()
        {
            var result = new List<EntidadFinanciera>();
            foreach (var item in _entFinanRepository.Find())
            {
                result.Add(new EntidadFinanciera(item));
            }

            return result;
        }

        public EntidadFinanciera Find(int entidadFinanId)
        {
            var data = _entFinanRepository.Find(entidadFinanId);
            if (data != null)
            {
                return new EntidadFinanciera(data);
            }
            return new EntidadFinanciera()
            {
                Response = new Response()
                {
                    Value = false,
                    Message = "No se encontraron resultados para el identificador de correo"
                }
            };
        }

        public Response Save(EntidadFinanciera entidadFinanciera, int currentUserId, SaveOption saveOption)
        {
            _entFinanRepository.I_EntidadFinanID = entidadFinanciera.Id;
            _entFinanRepository.T_EntidadDesc = entidadFinanciera.Nombre;
            _entFinanRepository.B_Habilitado = entidadFinanciera.Habilitado;

            switch (saveOption)
            {
                case SaveOption.Insert:
                    _entFinanRepository.D_FecCre = DateTime.Now;
                    return new Response(_entFinanRepository.Insert(currentUserId));

                case SaveOption.Update:
                    _entFinanRepository.D_FecMod = DateTime.Now;
                    return new Response(_entFinanRepository.Update(currentUserId));
            }

            return new Response()
            {
                Value = false,
                Message = "Operación Inváiida."
            };
        }
    }
}
